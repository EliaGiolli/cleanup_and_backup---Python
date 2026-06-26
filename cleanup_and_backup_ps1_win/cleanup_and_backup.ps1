<#
.SYNOPSIS
    Cleanup-And-Backup.ps1

.DESCRIPTION
    Windows/PowerShell counterpart to the Linux cleanup_and_backup.py script.
    Performs two classic sysadmin jobs:

    1. CLEANUP - Scans a folder (e.g. Downloads) and moves files older than
       N days into an archive folder, instead of letting junk accumulate.

    2. BACKUP  - Creates a compressed (.zip) snapshot of a projects/scripts
       folder and stores it in a backup destination - a local folder, a
       mounted USB drive (e.g. E:\Backups), or a OneDrive sync folder.

    Every action is logged to both the console and a log file, and -DryRun
    lets you preview everything with zero filesystem changes.

.PARAMETER SourceFolder
    Folder to scan for old files. Default: Downloads.

.PARAMETER ArchiveFolder
    Where old files get moved to.

.PARAMETER DaysOld
    Age threshold in days before a file is considered "old".

.PARAMETER Extensions
    File extensions treated as temporary/junk. Pass an empty array to match ALL files.

.PARAMETER ProjectFolder
    Folder to compress and back up.

.PARAMETER BackupFolder
    Destination for the zip backup - point this at a USB drive letter or OneDrive folder.

.PARAMETER DryRun
    Preview actions without moving files or creating the zip.

.EXAMPLE
    .\Cleanup-And-Backup.ps1 -DryRun
    Preview what the script would do, with default settings.

.EXAMPLE
    .\Cleanup-And-Backup.ps1 -SourceFolder "$env:USERPROFILE\Desktop" -DaysOld 14 -BackupFolder "E:\Backups"
    Real run, scanning Desktop for files older than 14 days, backing up to a USB drive.
#>

[CmdletBinding()]
param (
    [string]$SourceFolder   = "$env:USERPROFILE\Downloads",
    [string]$ArchiveFolder  = "$env:USERPROFILE\Downloads\_old_files_archive",
    [int]$DaysOld           = 30,
    [string[]]$Extensions   = @(".tmp", ".temp", ".log", ".crdownload", ".part"),
    [string]$ProjectFolder  = "$env:USERPROFILE\Projects",
    [string]$BackupFolder   = "$env:USERPROFILE\Backups",
    [switch]$DryRun
)

# Keep the log file in the user profile root so it's easy to find regardless
# of which folder the script is launched from (e.g. via Task Scheduler).
$LogFile = "$env:USERPROFILE\cleanup_backup.log"


function Write-Log {
    <#
    Writes a timestamped line to BOTH the console and the log file.
    Sysadmin scripts should never run silently - if Task Scheduler runs this
    at 3 AM and something goes wrong, the log file is your only clue.
    #>
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "$timestamp [$Level] $Message"

    Write-Host $logLine
    Add-Content -Path $LogFile -Value $logLine
}


function Test-IsOldFile {
    <#
    Returns $true if the file's LastWriteTime is older than $MaxAgeDays.
    LastWriteTime is the Windows equivalent of Linux's mtime - it's updated
    whenever the file's content changes, and is the standard, reliable way
    to answer "how old is this file?" on any Windows filesystem (NTFS, etc.).
    #>
    param (
        [System.IO.FileInfo]$File,
        [int]$MaxAgeDays
    )
    $fileAge = (Get-Date) - $File.LastWriteTime
    return $fileAge.TotalDays -gt $MaxAgeDays
}


function Move-OldFiles {
    <#
    Scans $SourceDir (top level only - no recursion into subfolders, since
    Downloads/Desktop are usually flat) for files older than $MaxAgeDays
    whose extension matches the "temporary file" list, and MOVES them into
    $ArchiveDir rather than deleting them outright.

    Moving (not deleting) is safer and trivially reversible. If you want
    items to land in the actual Windows Recycle Bin instead, you'd reach for
    a helper module like Recycle (Install-Module Recycle) - this script
    intentionally avoids extra dependencies and uses a plain archive folder.

    Returns the number of files moved.
    #>
    param (
        [string]$SourceDir,
        [string]$ArchiveDir,
        [int]$MaxAgeDays,
        [string[]]$TargetExtensions,
        [bool]$IsDryRun
    )

    if (-not (Test-Path $ArchiveDir)) {
        New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
    }

    $movedCount = 0

    # -File restricts results to files only - the direct equivalent of the
    # "if item.is_dir(): continue" guard in the Python version. This matters:
    # without it, a folder like a browser's "Downloading" temp directory
    # could get scooped up by mistake.
    $candidates = Get-ChildItem -Path $SourceDir -File

    foreach ($item in $candidates) {

        # If the caller passed an empty extension array, treat EVERY file as
        # a candidate. Otherwise only match the given "junk" extensions.
        $matchesExtension = ($TargetExtensions.Count -eq 0) -or
                             ($TargetExtensions -contains $item.Extension.ToLower())

        if ($matchesExtension -and (Test-IsOldFile -File $item -MaxAgeDays $MaxAgeDays)) {
            $destination = Join-Path $ArchiveDir $item.Name

            # Guard against overwriting a same-named file already archived,
            # by appending a timestamp to the new copy.
            if (Test-Path $destination) {
                $ts = Get-Date -Format "yyyyMMdd_HHmmss"
                $newName = "{0}_{1}{2}" -f $item.BaseName, $ts, $item.Extension
                $destination = Join-Path $ArchiveDir $newName
            }

            if ($IsDryRun) {
                # Dry-run mode: report what WOULD happen, touch nothing.
                Write-Log "[DRY-RUN] Would move: $($item.FullName) -> $destination"
            }
            else {
                Move-Item -Path $item.FullName -Destination $destination -Force
                Write-Log "Moved old file: $($item.Name) -> $destination"
            }

            $movedCount++
        }
    }

    return $movedCount
}


function Backup-ProjectFolder {
    <#
    Compresses $ProjectDir into a timestamped .zip and stores it in
    $BackupDir. BackupDir can be:
      - a local folder (default)
      - a USB drive letter, e.g. "E:\Backups"
      - a OneDrive sync folder on disk, e.g. "$env:USERPROFILE\OneDrive\Backups"
        (the OneDrive client then syncs the zip automatically)

    Compress-Archive is built into PowerShell 5.1+ (shipped natively with
    Windows 10/11) - no external modules required, the direct counterpart
    to Python's zipfile module.

    Returns the path of the created (or, in dry-run, intended) zip file.
    #>
    param (
        [string]$ProjectDir,
        [string]$BackupDir,
        [bool]$IsDryRun
    )

    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    }

    $timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
    $projectName = Split-Path $ProjectDir -Leaf
    $zipName     = "{0}_backup_{1}.zip" -f $projectName, $timestamp
    $zipPath     = Join-Path $BackupDir $zipName

    if ($IsDryRun) {
        Write-Log "[DRY-RUN] Would create backup archive: $zipPath"
        return $zipPath
    }

    # "\*" copies the CONTENTS of ProjectDir into the zip root, rather than
    # nesting everything inside an extra folder layer when extracted.
    Compress-Archive -Path "$ProjectDir\*" -DestinationPath $zipPath -CompressionLevel Optimal -Force

    $sizeKB = [math]::Round((Get-Item $zipPath).Length / 1KB, 1)
    Write-Log "Backup created: $zipPath ($sizeKB KB)"
    return $zipPath
}


# ===================== MAIN =====================

Write-Log "=== Starting cleanup & backup run ==="
if ($DryRun) {
    Write-Log "DRY-RUN mode active: no files will actually be moved or created."
}

# --- Job 1: clean old temp files ---
if (-not (Test-Path $SourceFolder)) {
    Write-Log "Source folder not found, skipping cleanup: $SourceFolder" "WARN"
}
else {
    $normalizedExtensions = $Extensions | ForEach-Object { $_.ToLower() }
    $moved = Move-OldFiles -SourceDir $SourceFolder -ArchiveDir $ArchiveFolder `
                            -MaxAgeDays $DaysOld -TargetExtensions $normalizedExtensions `
                            -IsDryRun $DryRun.IsPresent
    Write-Log "Cleanup complete: $moved file(s) processed."
}

# --- Job 2: backup the project folder ---
if (-not (Test-Path $ProjectFolder)) {
    Write-Log "Project folder not found, skipping backup: $ProjectFolder" "WARN"
}
else {
    Backup-ProjectFolder -ProjectDir $ProjectFolder -BackupDir $BackupFolder -IsDryRun $DryRun.IsPresent
}

Write-Log "=== Run finished ==="