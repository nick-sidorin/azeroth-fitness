#!/usr/bin/env python3
"""Validate the Forever addon manifest and build a verified installable ZIP.

The .toc file is the single source of truth for runtime contents. This avoids
publishing a build that passes Lua tests but accidentally omits a new module.
No third-party Python dependencies are required.
"""
from __future__ import annotations

import re
import sys
import zipfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT
TOC = ADDON / "AzerothFitness.toc"
LICENSE = ADDON / "LICENSE"
VERSION_RE = re.compile(r"^## Version:\s*(\d+\.\d+\.\d+)\s*$")
REL_PATTERN = re.compile(r"^[A-Za-z0-9._/-]+$")


def source_path(name: str) -> Path:
    return ROOT.joinpath(*PurePosixPath(name).parts[1:])


def manifest() -> tuple[str, list[str]]:
    if not TOC.is_file() or not LICENSE.is_file():
        raise ValueError("Missing addon TOC or LICENSE")

    contents = TOC.read_text(encoding="utf-8-sig").splitlines()
    versions = [m.group(1) for line in contents if (m := VERSION_RE.match(line))]
    if len(versions) != 1:
        raise ValueError("Expected exactly one three-part version in TOC")

    for key, value in {"Interface": "16001", "AllowLoadGameType": "camelot",
                       "SavedVariables": "AzerothFitnessDB"}.items():
        values = [line.split(":", 1)[1].strip() for line in contents
                  if line.startswith(f"## {key}:")]
        if values != [value]:
            raise ValueError(f"Expected exactly one {key}: {value}")
    core_versions = re.findall(r'^AF.VERSION = "([^\"]+)"$',
                               (ROOT / "Core.lua").read_text(encoding="utf-8"), re.M)
    if core_versions != versions:
        raise ValueError("Core.lua and TOC versions differ")

    listed: list[str] = []
    for line in contents:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if not REL_PATTERN.fullmatch(line):
            raise ValueError(f"Unexpected TOC path: {line!r}")
        part = PurePosixPath(line.replace("\\", "/"))
        if part.is_absolute() or ".." in part.parts or str(part) != line.replace("\\", "/"):
            raise ValueError(f"Unsafe TOC entry: {line!r}")
        if part.suffix.lower() not in {".lua", ".xml"}:
            raise ValueError(f"Unsupported runtime entry: {line!r}")
        if part.suffix.lower() == ".xml":
            raise ValueError("XML requires a recursive include/script and asset-inventory gate before packaging")
        relative = f"AzerothFitness/{part.as_posix()}"
        if relative in listed:
            raise ValueError(f"Repeated TOC entry: {relative}")
        path = source_path(relative)
        if path.is_symlink() or not path.resolve().is_relative_to(ROOT):
            raise ValueError(f"TOC entry escapes source tree: {relative}")
        if not path.is_file() or not path.stat().st_size:
            raise ValueError(f"TOC references missing file: {relative}")
        listed.append(relative)

    if listed[:2] != ["AzerothFitness/Locale.lua", "AzerothFitness/LocaleTranslations.lua"]:
        raise ValueError("Locale.lua and LocaleTranslations.lua must load before consumers")

    if listed[-1] != "AzerothFitness/Bootstrap.lua":
        raise ValueError("Bootstrap.lua must load last")

    actual_sources = {
        f"AzerothFitness/{path.name}"
        for path in ADDON.iterdir()
        if path.is_file() and path.suffix.lower() in {".lua", ".xml"}
    }
    if set(listed) != actual_sources:
        raise ValueError(
            f"Runtime files differ from TOC; missing in manifest: {sorted(actual_sources - set(listed))}; "
            f"missing from disk: {sorted(set(listed) - actual_sources)}"
        )

    return versions[0], [
        "AzerothFitness/AzerothFitness.toc",
        *listed,
        "AzerothFitness/LICENSE",
    ]


def verify_zip(output: Path, expected: list[str]) -> None:
    with zipfile.ZipFile(output) as archive:
        names = archive.namelist()
        if names != expected or len(names) != len(set(names)):
            raise ValueError(f"Archive contents differ from TOC: {names!r}")
        if archive.testzip() is not None:
            raise ValueError("Corrupt ZIP member")
        for name in names:
            if archive.read(name) != source_path(name).read_bytes():
                raise ValueError(f"ZIP contents differ from source: {name}")


def main() -> None:
    version, expected = manifest()
    if len(sys.argv) == 2 and sys.argv[1] == "--check":
        print(f"Verified TOC v{version} and {len(expected)} installable files")
        return
    if len(sys.argv) != 2:
        raise ValueError("Usage: python3 scripts/package_addon.py --check | dist/AzerothFitness-vX.Y.Z.zip")
    path = Path(sys.argv[1])
    pattern = re.compile(
        rf"AzerothFitness-v{re.escape(version)}(?:-(?:alpha|beta)(?:\.\d+)?)?\.zip$"
    )
    if not pattern.fullmatch(path.name):
        raise ValueError(f"ZIP name does not match TOC version v{version}: {path.name}")
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name in expected:
            info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            archive.writestr(info, source_path(name).read_bytes())
    verify_zip(path, expected)
    print(f"Built and verified {path} with {len(expected)} exact runtime files")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, zipfile.BadZipFile) as error:
        print(f"RELEASE GATE FAILED: {error}", file=sys.stderr)
        sys.exit(1)
