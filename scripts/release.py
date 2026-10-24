#!/usr/bin/env python3
"""Keep release versions, Git tags and release notes consistent."""
import argparse
import os
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
VERSION = re.compile(r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$')


def read_version(root=ROOT):
    text = (root / 'pubspec.yaml').read_text()
    match = re.search(r'^version: (\S+)$', text, re.M)
    if not match:
        raise ValueError('pubspec.yaml has no version')
    name, build = match[1].split('+')
    if not VERSION.fullmatch(name) or not build.isdecimal():
        raise ValueError('Use MAJOR.MINOR.PATCH+BUILD')
    if not 1 <= int(build) <= 65535 or any(int(n) > 65535 for n in name.split('.')):
        raise ValueError('Version components and build must fit Windows version fields')
    return name, int(build)


def verify(root=ROOT, tag=None):
    name, build = read_version(root)
    full = f'{name}+{build}'
    if f"const kAppVersion = '{full}';" not in (root / 'lib/version.dart').read_text():
        raise ValueError('lib/version.dart does not match pubspec.yaml')
    if tag is not None and tag != f'v{name}':
        raise ValueError(f'Tag {tag} does not match v{name}')
    if f'## [{name}]' not in (root / 'CHANGELOG.md').read_text():
        raise ValueError(f'CHANGELOG.md has no entry for {name}')
    return name, build


def set_version(name, build=None, root=ROOT):
    old_name, old_build = read_version(root)
    if not VERSION.fullmatch(name):
        raise ValueError('Use MAJOR.MINOR.PATCH')
    if tuple(map(int, name.split('.'))) <= tuple(map(int, old_name.split('.'))):
        raise ValueError('Release version must increase')
    build = old_build + 1 if build is None else build
    if not old_build < build <= 65535 or any(int(n) > 65535 for n in name.split('.')):
        raise ValueError('Build number must increase and version fields must fit Windows')
    p = root / 'pubspec.yaml'
    p.write_text(re.sub(r'^version: \S+$', f'version: {name}+{build}', p.read_text(), flags=re.M))
    (root / 'lib/version.dart').write_text(
        '/// Updated together with pubspec.yaml by scripts/release.py.\n'
        f"const kAppVersion = '{name}+{build}';\n")
    return name, build


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    check = sub.add_parser('verify')
    check.add_argument('--tag')
    bump = sub.add_parser('set-version')
    bump.add_argument('version')
    bump.add_argument('--build', type=int)
    args = parser.parse_args()
    try:
        name, build = verify(tag=args.tag) if args.command == 'verify' else set_version(args.version, args.build)
    except (ValueError, FileNotFoundError) as error:
        parser.error(str(error))
    if output := os.environ.get('GITHUB_OUTPUT'):
        with open(output, 'a') as f:
            f.write(f'version={name}\nbuild={build}\n')
    print(f'ReadTrack {name}+{build}')


if __name__ == '__main__':
    main()
