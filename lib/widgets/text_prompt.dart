import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// Asks for a line or a few lines of text; returns null when cancelled.
///
/// The dialog owns its controller, so it isn't disposed while the closing
/// animation still shows the field.
Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  String? hint,
  String? initial,
  Widget? header,
  bool multiline = false,
}) => showDialog<String>(
  context: context,
  builder: (context) => _TextPrompt(
    title: title,
    hint: hint,
    initial: initial,
    header: header,
    multiline: multiline,
  ),
);

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({
    required this.title,
    this.hint,
    this.initial,
    this.header,
    this.multiline = false,
  });

  final String title;
  final String? hint;
  final String? initial;
  final Widget? header;
  final bool multiline;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?widget.header,
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: widget.multiline ? 2 : 1,
              maxLines: widget.multiline ? 6 : 1,
              decoration: InputDecoration(hintText: widget.hint),
              onSubmitted: widget.multiline ? null : (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
