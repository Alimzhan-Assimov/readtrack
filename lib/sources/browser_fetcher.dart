import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_webview_window/desktop_webview_window.dart';

import 'fetcher.dart';

/// Loads pages through a real browser window (WebKitGTK on Linux), for sites
/// protected by Cloudflare. The window stays open while a session runs, so
/// the user can solve a challenge if the site asks for one; cookies persist
/// between sessions, so that is rarely needed twice.
///
/// Requests made with [getText] navigate the window; [postForm] and
/// [getBytes] run `fetch()` inside the current page, so they share its
/// cookies and must target the same site.
class BrowserFetcher implements PageFetcher {
  BrowserFetcher({
    this.windowTitle = 'ReadTrack',
    Duration minInterval = const Duration(milliseconds: 1500),
  }) : _limiter = RateLimiter(minInterval);

  static bool get isSupported =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  /// How long to wait for a page, including time for the user to solve a
  /// Cloudflare challenge in the window.
  static const _pageTimeout = Duration(minutes: 3);
  static const _bridge = 'readtrack';

  final String windowTitle;
  final RateLimiter _limiter;
  Webview? _view;
  Future<Webview>? _creating;
  var _nextRequestId = 0;
  final _pending = <int, Completer<Object?>>{};

  Future<Webview> _webview() {
    final view = _view;
    if (view != null) return Future.value(view);
    return _creating ??= _create();
  }

  Future<Webview> _create() async {
    try {
      final view = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowWidth: 960,
          windowHeight: 720,
          title: windowTitle,
          titleBar: const TitleBarOptions(showNavigation: false),
        ),
      );
      view.addJavaScriptHandler(_bridge, (data, origin) {
        if (data is! Map) return;
        final completer = _pending.remove(data['id']);
        if (completer == null) return;
        if (data['ok'] == true) {
          completer.complete(data['body']);
        } else {
          completer.completeError(
            SourceException('Request failed: ${data['error']}'),
          );
        }
      });
      unawaited(
        view.onClose.then((_) {
          _view = null;
          for (final c in _pending.values) {
            c.completeError(SourceException('The browser window was closed.'));
          }
          _pending.clear();
        }),
      );
      _view = view;
      return view;
    } on Exception catch (e) {
      throw SourceException('Could not open the browser window: $e');
    } finally {
      _creating = null;
    }
  }

  /// Navigates to [uri] and waits until the real page (not a Cloudflare
  /// challenge) has finished loading.
  Future<void> _load(Uri uri) async {
    await _limiter.wait(uri.host);
    final view = await _webview();
    await view.launch(uri.toString(), triggerOnUrlRequestEvent: false);
    final deadline = DateTime.now().add(_pageTimeout);
    // Give the navigation a moment to start before polling its state.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    while (true) {
      if (_view == null) {
        throw SourceException('The browser window was closed.');
      }
      final state = await view.evaluateJavaScript('''
        (function () {
          var challenge = document.title.indexOf('Just a moment') >= 0 ||
            !!document.querySelector('#challenge-form, #cf-challenge-running, .cf-turnstile, #challenge-stage');
          return {ready: document.readyState === 'complete', challenge: challenge, host: location.host};
        })()
      ''');
      if (state is Map &&
          state['ready'] == true &&
          state['challenge'] != true &&
          state['host'] == uri.host &&
          !view.navigationState.value.isLoading) {
        return;
      }
      if (DateTime.now().isAfter(deadline)) {
        throw SourceException(
          '${uri.host} did not finish loading. If the window shows a '
          'verification, solve it and try again.',
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<String> getText(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    await _load(uri);
    final html = await _view!.evaluateJavaScript(
      'document.documentElement.outerHTML',
    );
    if (html is! String) {
      throw SourceException('Could not read the page from ${uri.host}.');
    }
    return html;
  }

  @override
  Future<({String body, Map<String, String> headers})> getWithHeaders(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async => (body: await getText(uri), headers: const <String, String>{});

  /// Runs `fetch()` in the current page and returns its body as text, or as
  /// base64 when [binary] is set.
  Future<String> _fetch(
    Uri uri, {
    String method = 'GET',
    Map<String, String> fields = const {},
    bool binary = false,
  }) async {
    final view = await _webview();
    final current = Uri.tryParse(view.navigationState.value.url ?? '');
    if (current == null || current.host != uri.host) {
      // fetch() needs a page of the same site for its cookies.
      await _load(uri.replace(path: '/', query: ''));
    }
    await _limiter.wait(uri.host);
    final id = _nextRequestId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;
    final options = method == 'POST'
        ? '{method: "POST", credentials: "include", headers: {"Content-Type": "application/x-www-form-urlencoded; charset=UTF-8", "X-Requested-With": "XMLHttpRequest"}, body: ${jsonEncode(Uri(queryParameters: fields).query)}}'
        : '{credentials: "include"}';
    final read = binary
        ? '''r.arrayBuffer().then(function (b) {
              var bytes = new Uint8Array(b), s = '';
              for (var i = 0; i < bytes.length; i += 0x8000) {
                s += String.fromCharCode.apply(null, bytes.subarray(i, i + 0x8000));
              }
              return btoa(s);
            })'''
        : 'r.text()';
    await view.evaluateJavaScript('''
      fetch(${jsonEncode(uri.toString())}, $options)
        .then(function (r) {
          if (!r.ok) throw new Error('HTTP ' + r.status);
          return $read;
        })
        .then(function (body) { window.desktopWebview.postMessage('$_bridge', {id: $id, ok: true, body: body}); })
        .catch(function (e) { window.desktopWebview.postMessage('$_bridge', {id: $id, ok: false, error: String(e)}); });
      true;
    ''');
    final body = await completer.future.timeout(
      const Duration(minutes: 1),
      onTimeout: () {
        _pending.remove(id);
        throw SourceException('${uri.host} did not respond in time.');
      },
    );
    return body as String? ?? '';
  }

  /// Extra [headers] are not needed here: requests run inside the page,
  /// which already carries the site's cookies and tokens.
  @override
  Future<String> postForm(
    Uri uri,
    Map<String, String> fields, {
    Map<String, String> headers = const {},
  }) => _fetch(uri, method: 'POST', fields: fields);

  @override
  Future<Uint8List> getBytes(Uri uri) async =>
      base64Decode(await _fetch(uri, binary: true));

  /// Runs `fetch()` for [uri] in the current page and returns the text.
  Future<String> fetchInPage(Uri uri) => _fetch(uri);

  /// Evaluates [javaScript] in the current page, e.g. to read a cookie.
  Future<Object?> evaluate(String javaScript) async =>
      (await _webview()).evaluateJavaScript(javaScript);

  @override
  Future<void> close() async {
    final view = _view;
    _view = null;
    await view?.close();
  }
}
