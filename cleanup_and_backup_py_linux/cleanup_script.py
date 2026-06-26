#!/usr/bin/env python3
"""
cleanup_and_backup.py

A classic sysadmin/helpdesk utility script with two jobs:

1. CLEANUP  - Scan a folder (e.g. ~/Downloads) and move files older than
              N days into an "archive" folder, instead of letting junk
              pile up and eat disk space.

2. BACKUP   - Create a compressed (.zip) snapshot of a scripts/projects
              folder and store it in a backup destination, which could be
              a local folder, a mounted USB drive, or a OneDrive/Dropbox
              sync folder on disk.

Both actions are logged to a file so you have an audit trail of what the
script did and when - exactly what you'd want on a real machine.

Run "python3 cleanup_and_backup.py --help" to see all configurable options.
"""

import argparse
import logging
import shutil
import sys
import zipfile
from datetime import datetime, timedelta
from pathlib import Path


def setup_logging(log_file: Path) -> None:
    """
    Configure logging so every action is printed to the console AND
    appended to a log file. Sysadmin scripts should never run silently -
    if something breaks at 3 AM via cron, the log file is your only clue.
    """
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.FileHandler(log_file, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def is_old_file(file_path: Path, max_age_days: int) -> bool:
    """
    Check whether a file's last MODIFICATION time is older than max_age_days.

    Note: we use mtime (modification time), not creation time. Linux/ext4
    doesn't expose a reliable, portable "creation date" the way Windows does -
    mtime is the standard, cross-platform way to answer "how old is this file?"
    """
    file_age = datetime.now() - datetime.fromtimestamp(file_path.stat().st_mtime)
    return file_age > timedelta(days=max_age_days)


def clean_old_files(source_dir: Path, archive_dir: Path, max_age_days: int,
                     extensions: list, dry_run: bool) -> int:
    """
    Scan source_dir (top level only - we don't recurse into subfolders,
    since Downloads/Desktop are usually flat) for files older than
    max_age_days whose extension matches the "temporary file" list.

    Files are MOVED into archive_dir rather than deleted outright.
    This is safer than the system Trash/Recycle Bin approach because:
      - it works identically on every Linux distro (no desktop-environment
        dependency on how "Trash" is implemented)
      - it's trivially reversible: just move the file back
    If you specifically want OS-level Trash integration, the third-party
    'send2trash' package (pip install send2trash) does that job instead.

    Returns the number of files moved.
    """
    archive_dir.mkdir(parents=True, exist_ok=True)
    moved_count = 0

    for item in source_dir.iterdir():
        # Skip subdirectories - we only manage files sitting directly
        # in the scanned folder, not nested folder structures.
        if item.is_dir():
            continue

        # If the user passed an empty extension list, treat EVERY file as
        # a candidate. Otherwise only match the given "junk" extensions.
        matches_extension = (not extensions) or (item.suffix.lower() in extensions)

        if matches_extension and is_old_file(item, max_age_days):
            destination = archive_dir / item.name

            # Guard against overwriting a file already archived with the
            # same name, by appending a timestamp to the new copy.
            if destination.exists():
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                destination = archive_dir / f"{item.stem}_{timestamp}{item.suffix}"

            if dry_run:
                # Dry-run mode: show what WOULD happen without touching anything.
                # Always test destructive scripts this way before trusting them.
                logging.info(f"[DRY-RUN] Would move: {item} -> {destination}")
            else:
                shutil.move(str(item), str(destination))
                logging.info(f"Moved old file: {item.name} -> {destination}")

            moved_count += 1

    return moved_count


def backup_project_folder(project_dir: Path, backup_dir: Path, dry_run: bool) -> Path:
    """
    Compress project_dir into a timestamped .zip file and store it inside
    backup_dir. backup_dir can be:
      - a local folder (default)
      - a mounted USB drive, e.g. /media/youruser/USBDRIVE/Backups
      - a OneDrive/Dropbox sync folder on disk, e.g. ~/OneDrive/Backups
        (the cloud client then syncs the zip automatically)

    Each backup gets its own filename with a timestamp, so running this
    daily/weekly via cron builds up a history instead of overwriting
    the previous backup - which is the whole point of a backup strategy.

    Returns the path of the created (or, in dry-run, intended) zip file.
    """
    backup_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    zip_name = f"{project_dir.name}_backup_{timestamp}.zip"
    zip_path = backup_dir / zip_name

    if dry_run:
        logging.info(f"[DRY-RUN] Would create backup archive: {zip_path}")
        return zip_path

    # ZIP_DEFLATED = actual compression (the default ZIP_STORED would just
    # bundle files together uncompressed, defeating the purpose of zipping).
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for file_path in project_dir.rglob("*"):
            if file_path.is_file():
                # arcname makes paths INSIDE the zip relative to the parent
                # of project_dir, so extracting the zip recreates the folder
                # structure cleanly instead of dumping absolute host paths.
                arcname = file_path.relative_to(project_dir.parent)
                zipf.write(file_path, arcname)

    size_kb = zip_path.stat().st_size / 1024
    logging.info(f"Backup created: {zip_path} ({size_kb:.1f} KB)")
    return zip_path


def parse_arguments() -> argparse.Namespace:
    """
    Define command-line flags so this script is reusable and schedulable
    (e.g. via cron) without editing the source every time you need
    different paths or settings.
    """
    parser = argparse.ArgumentParser(
        description="Clean up old temp files and back up a project folder."
    )
    parser.add_argument(
        "--source", type=Path, default=Path.home() / "Downloads",
        help="Folder to scan for old files (default: ~/Downloads)"
    )
    parser.add_argument(
        "--archive", type=Path, default=Path.home() / "Downloads" / "_old_files_archive",
        help="Folder where old files get moved to (default: ~/Downloads/_old_files_archive)"
    )
    parser.add_argument(
        "--days", type=int, default=30,
        help="Age threshold in days before a file is considered 'old' (default: 30)"
    )
    parser.add_argument(
        "--extensions", nargs="*",
        default=[".tmp", ".temp", ".log", ".crdownload", ".part"],
        help="File extensions treated as temporary/junk (pass nothing to match ALL files)"
    )
    parser.add_argument(
        "--project-dir", type=Path, default=Path.home() / "projects",
        help="Folder to compress and back up (default: ~/projects)"
    )
    parser.add_argument(
        "--backup-dir", type=Path, default=Path.home() / "Backups",
        help="Destination for the zip backup - point this at a mounted USB or OneDrive folder (default: ~/Backups)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Preview actions without moving files or creating the zip"
    )
    return parser.parse_args()


def main() -> None:
    args = parse_arguments()

    # Keep the log file in the home directory so it's easy to find regardless
    # of which folder the script is run from (e.g. via cron, the working
    # directory may not be what you expect).
    log_file = Path.home() / "cleanup_backup.log"
    setup_logging(log_file)

    logging.info("=== Starting cleanup & backup run ===")
    if args.dry_run:
        logging.info("DRY-RUN mode active: no files will actually be moved or created.")

    # --- Job 1: clean old temp files ---
    if not args.source.exists():
        logging.warning(f"Source folder not found, skipping cleanup: {args.source}")
    else:
        normalized_extensions = [ext.lower() for ext in args.extensions]
        moved = clean_old_files(args.source, args.archive, args.days,
                                 normalized_extensions, args.dry_run)
        logging.info(f"Cleanup complete: {moved} file(s) processed.")

    # --- Job 2: backup the project folder ---
    if not args.project_dir.exists():
        logging.warning(f"Project folder not found, skipping backup: {args.project_dir}")
    else:
        backup_project_folder(args.project_dir, args.backup_dir, args.dry_run)

    logging.info("=== Run finished ===")


if __name__ == "__main__":
    main()