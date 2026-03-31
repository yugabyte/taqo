#!/usr/bin/env python3
import argparse
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / 'dist'

INCLUDE_DIRS = [
    'src', 'sql', 'bin', 'scripts', 'config', 'docker', 'adoc', 'system-catalog', 'report'
]
INCLUDE_FILES = ['README.md', 'LICENSE', 'requirements.txt']
EXCLUDES = ['.git', 'venv', '.venv', '__pycache__']


def make_archive(version: str) -> Path:
    DIST.mkdir(exist_ok=True)

    archive_name = f"TAQO-{version}.tar.gz"
    archive_path = DIST / archive_name

    # Only include files/dirs that actually exist
    include_items = [p for p in (INCLUDE_FILES + INCLUDE_DIRS) if (ROOT / p).exists()]

    # Build tar.gz
    tar_cmd = [
        'tar', '--exclude-vcs',
        '--exclude=venv', '--exclude=.venv', '--exclude=.git', '--exclude=*/__pycache__',
        '-czf', str(archive_path), '-C', str(ROOT)
    ] + include_items
    subprocess.check_call(tar_cmd)

    # Zip only SQL models
    sql_zip = DIST / f"models-{version}.zip"
    if sql_zip.exists():
        sql_zip.unlink()
    if (ROOT / 'sql').exists():
        subprocess.check_call(['zip', '-r', str(sql_zip), '.'], cwd=ROOT / 'sql')

    # Checksums
    with open(DIST / 'SHA256SUMS.txt', 'w') as sums:
        for f in [archive_path, sql_zip]:
            sha = subprocess.check_output(['shasum', '-a', '256', str(f)]).decode('utf-8')
            sums.write(sha)

    return archive_path


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Build release artifacts including SQL models')
    parser.add_argument('--version', required=True, help='Version string (e.g., 1.2.3)')
    args = parser.parse_args()

    make_archive(args.version)
    print('Artifacts written to dist/')
