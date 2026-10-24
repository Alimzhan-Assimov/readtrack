import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('release', Path(__file__).parents[1] / 'release.py')
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'lib').mkdir()
        (self.root / 'pubspec.yaml').write_text('name: readtrack\nversion: 1.0.0+1\n')
        (self.root / 'lib/version.dart').write_text("const kAppVersion = '1.0.0+1';\n")
        (self.root / 'CHANGELOG.md').write_text('## [1.0.0]\n## [1.1.0]\n')

    def test_tag_and_runtime_version_must_match(self):
        self.assertEqual(release.verify(self.root, 'v1.0.0'), ('1.0.0', 1))
        with self.assertRaisesRegex(ValueError, 'Tag'):
            release.verify(self.root, 'v9.0.0')
        (self.root / 'lib/version.dart').write_text("const kAppVersion = '9.0.0+1';")
        with self.assertRaisesRegex(ValueError, 'does not match'):
            release.verify(self.root)

    def test_updates_increase_android_build_number_and_both_versions(self):
        release.set_version('1.1.0', root=self.root)
        self.assertEqual(release.verify(self.root, 'v1.1.0'), ('1.1.0', 2))
        with self.assertRaisesRegex(ValueError, 'must increase'):
            release.set_version('1.2.0', build=1, root=self.root)
        with self.assertRaisesRegex(ValueError, 'must increase'):
            release.set_version('1.0.0', root=self.root)

    def test_missing_release_notes_fail_before_publishing(self):
        (self.root / 'CHANGELOG.md').write_text('# Changelog\n')
        with self.assertRaisesRegex(ValueError, 'no entry'):
            release.verify(self.root)


if __name__ == '__main__':
    unittest.main()
