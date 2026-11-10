"""Exercise actual Git snapshots, pinned sync, offline integrity and invalid input."""
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

TOOL = Path(__file__).resolve().parents[1] / "scripts" / "standards.py"


class StandardsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.source = Path(self.temp.name) / "source"
        self.target = Path(self.temp.name) / "target"
        self.source.mkdir()
        self.target.mkdir()
        self.git("init", "-q")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        self.git("remote", "add", "origin", "https://github.com/nick-sidorin/wow-addon-standards.git")
        for name, value in {"AGENTS.md": "reviewed rules\n", "FIELD_NOTES.md": "reviewed evidence\n", "VERSION": "0.1.0\n"}.items():
            (self.source / name).write_text(value)
        self.git("add", ".")
        self.git("commit", "-qm", "Reviewed fixture")
        self.commit = self.git("rev-parse", "HEAD").strip()

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.source), *args], text=True)

    def run_tool(self, *args, success=True):
        result = subprocess.run([sys.executable, str(TOOL), *args, "--target", str(self.target)], capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def sync(self, commit=None, success=True):
        return self.run_tool("sync", "--source", str(self.source), "--commit", commit or self.commit, success=success)

    def test_reads_pinned_snapshot_and_preserves_local_profile(self):
        (self.source / "AGENTS.md").write_text("unreviewed working tree\n")
        (self.target / "AGENTS.md").write_text("local profile\n")
        self.sync()
        self.assertEqual((self.target / "docs/standards/AGENTS.md").read_text(), "reviewed rules\n")
        self.assertEqual((self.target / "AGENTS.md").read_text(), "local profile\n")
        self.run_tool("check")

    def test_tampering_and_unexpected_inventory_are_rejected(self):
        self.sync()
        (self.target / "docs/standards/AGENTS.md").write_text("changed\n")
        self.run_tool("check", success=False)
        self.sync()
        path = self.target / "docs/standards/standards.lock.json"
        lock = json.loads(path.read_text())
        lock["files"]["../../AGENTS.md"] = "0" * 64
        path.write_text(json.dumps(lock))
        self.run_tool("check", success=False)

    def test_moving_ref_and_wrong_origin_do_not_write_target(self):
        self.sync("main", success=False)
        self.git("remote", "set-url", "origin", "https://example.invalid/other")
        self.sync(success=False)
        self.assertFalse((self.target / "docs").exists())


if __name__ == "__main__":
    unittest.main()
