"""Exercise packaging gates using isolated copies, never editing the checkout."""
import importlib.util
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class PackagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for source in [*ROOT.glob('*.lua'), ROOT / 'AzerothFitness.toc', ROOT / 'LICENSE']:
            shutil.copy2(source, self.root / source.name)
        (self.root / 'scripts').mkdir()
        shutil.copy2(ROOT / 'scripts/package_addon.py', self.root / 'scripts/package_addon.py')

    def run_gate(self, argument='--check', success=True):
        result = subprocess.run([sys.executable, 'scripts/package_addon.py', argument],
                                cwd=self.root, capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def toc(self, transform):
        path = self.root / 'AzerothFitness.toc'
        path.write_text(transform(path.read_text()))

    def test_installable_archive_and_reproducible_bytes(self):
        (self.root / 'AGENTS.md').write_text('Internal documentation')
        standards = self.root / 'docs/standards'
        standards.mkdir(parents=True)
        (standards / 'AGENTS.md').write_text('Development-only standards')
        (standards / 'standards.lock.json').write_text('{}')
        name = 'dist/AzerothFitness-v0.1.0.zip'
        self.run_gate(name)
        output = self.root / name
        first = output.read_bytes()
        with zipfile.ZipFile(output) as archive:
            expected = ['AzerothFitness/AzerothFitness.toc', *[
                'AzerothFitness/' + line for line in (self.root / 'AzerothFitness.toc').read_text().splitlines()
                if line and not line.startswith('#')], 'AzerothFitness/LICENSE']
            self.assertEqual(archive.namelist(), expected)
            self.assertIsNone(archive.testzip())
            for member in archive.namelist():
                self.assertEqual(archive.read(member), (self.root / member.split('/', 1)[1]).read_bytes())
        self.run_gate(name)
        self.assertEqual(first, output.read_bytes())

    def test_missing_module_is_rejected(self):
        (self.root / 'Jump.lua').unlink()
        self.run_gate(success=False)

    def test_unlisted_module_is_rejected(self):
        (self.root / 'Forgotten.lua').write_text('return true')
        self.run_gate(success=False)

    def test_duplicate_module_is_rejected(self):
        self.toc(lambda text: text.replace('Jump.lua', 'Jump.lua\nJump.lua'))
        self.run_gate(success=False)

    def test_unsafe_path_is_rejected(self):
        self.toc(lambda text: text.replace('Jump.lua', '../Jump.lua'))
        self.run_gate(success=False)

    def test_xml_cannot_silently_omit_dependencies(self):
        (self.root / 'Extra.xml').write_text('<Ui><Script file="Unlisted.lua"/></Ui>')
        self.toc(lambda text: text.replace('Jump.lua', 'Jump.lua\nExtra.xml'))
        result = self.run_gate(success=False)
        self.assertIn('recursive include', result.stderr)

    def test_version_and_client_metadata_are_checked(self):
        for old, new in [('Version: 0.1.0', 'Version: 0.1.1'),
                         ('Interface: 16001', 'Interface: 99999'),
                         ('AllowLoadGameType: camelot', 'AllowLoadGameType: mainline'),
                         ('SavedVariables: AzerothFitnessDB', 'SavedVariables: OtherDB')]:
            with self.subTest(old=old):
                original = (self.root / 'AzerothFitness.toc').read_text()
                self.toc(lambda text: text.replace(old, new))
                self.run_gate(success=False)
                (self.root / 'AzerothFitness.toc').write_text(original)

    def test_load_order_is_checked(self):
        self.toc(lambda text: text.replace('Locale.lua\nCore.lua', 'Core.lua\nLocale.lua'))
        self.run_gate(success=False)

    def test_filename_version_and_prereleases(self):
        self.run_gate('dist/AzerothFitness-v0.1.1.zip', success=False)
        self.run_gate('dist/AzerothFitness-v0.1.0-beta.1.zip')
        self.run_gate('dist/AzerothFitness-v0.1.0-alpha.zip')

    def test_zip_verifier_rejects_changed_bytes(self):
        path = self.root / 'scripts/package_addon.py'
        spec = importlib.util.spec_from_file_location('isolated_packager', path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        _, expected = module.manifest()
        archive = self.root / 'changed.zip'
        with zipfile.ZipFile(archive, 'w') as output:
            for name in expected:
                output.writestr(name, b'changed')
        with self.assertRaisesRegex(ValueError, 'differ from source'):
            module.verify_zip(archive, expected)


if __name__ == '__main__':
    unittest.main()
