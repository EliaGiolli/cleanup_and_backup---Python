<div align="center">
🪟🗂️ cleanup-and-backup (PowerShell Edition)

Automated cleanup & backup utility for Windows 11

Show Image
Show Image
Show Image
Show Image

Scan → Filter by age → Archive → Compress → Backup — fully logged, dry-run safe, Task Scheduler-ready.

</div>

📖 Overview

Cleanup-And-Backup.ps1 is a native PowerShell port of the Python/Linux version of this sysadmin utility — same two jobs, built entirely on tooling that ships with Windows 11 out of the box (no modules to install):


🧹 Cleanup — scans a folder (e.g. Downloads) and moves stale temporary files (older than N days) into an archive folder.
📦 Backup — creates a compressed, timestamped .zip snapshot of a projects folder and stores it locally, on a USB drive, or in a OneDrive sync folder.



✨ Features

🕒 Age-based filteringUses LastWriteTime to find files untouched for N+ days🗃️ Safe archiving, not deletionFiles are moved, never deleted — fully reversible🔐 Collision-safeAuto-renames archived files with a timestamp on name clash🗜️ Native compressionCompress-Archive — built into PowerShell 5.1+, no modules📝 Full audit logEvery action logged to console and cleanup_backup.log🧪 Dry-run mode-DryRun switch previews every action, zero filesystem changes⚙️ Fully parameterizedAll paths, thresholds, and extensions set via CLI flags⏰ Task Scheduler-readyDesigned to run unattended on a schedule


🔧 How It Works

#mermaid-r12m-r2 { font-family: "Anthropic Sans", system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 16px; fill: rgb(229, 229, 229); }
#mermaid-r12m-r2 .edge-animation-slow { stroke-dashoffset: 900; animation: 50s linear 0s infinite normal none running dash; stroke-linecap: round; stroke-dasharray: 9, 5 !important; }
#mermaid-r12m-r2 .edge-animation-fast { stroke-dashoffset: 900; animation: 20s linear 0s infinite normal none running dash; stroke-linecap: round; stroke-dasharray: 9, 5 !important; }
#mermaid-r12m-r2 .error-icon { fill: rgb(204, 120, 92); }
#mermaid-r12m-r2 .error-text { fill: rgb(51, 135, 163); stroke: rgb(51, 135, 163); }
#mermaid-r12m-r2 .edge-thickness-normal { stroke-width: 1px; }
#mermaid-r12m-r2 .edge-thickness-thick { stroke-width: 3.5px; }
#mermaid-r12m-r2 .edge-pattern-solid { stroke-dasharray: 0; }
#mermaid-r12m-r2 .edge-thickness-invisible { stroke-width: 0; fill: none; }
#mermaid-r12m-r2 .edge-pattern-dashed { stroke-dasharray: 3; }
#mermaid-r12m-r2 .edge-pattern-dotted { stroke-dasharray: 2; }
#mermaid-r12m-r2 .marker { fill: rgb(161, 161, 161); stroke: rgb(161, 161, 161); }
#mermaid-r12m-r2 .marker.cross { stroke: rgb(161, 161, 161); }
#mermaid-r12m-r2 svg { font-family: "Anthropic Sans", system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 16px; }
#mermaid-r12m-r2 p { margin: 0px; }
#mermaid-r12m-r2 .label { font-family: "Anthropic Sans", system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; color: rgb(229, 229, 229); }
#mermaid-r12m-r2 .cluster-label text { fill: rgb(51, 135, 163); }
#mermaid-r12m-r2 .cluster-label span { color: rgb(51, 135, 163); }
#mermaid-r12m-r2 .cluster-label span p { background-color: transparent; }
#mermaid-r12m-r2 .label text, #mermaid-r12m-r2 span { fill: rgb(229, 229, 229); color: rgb(229, 229, 229); }
#mermaid-r12m-r2 .node rect, #mermaid-r12m-r2 .node circle, #mermaid-r12m-r2 .node ellipse, #mermaid-r12m-r2 .node polygon, #mermaid-r12m-r2 .node path { fill: transparent; stroke: rgb(161, 161, 161); stroke-width: 1px; }
#mermaid-r12m-r2 .rough-node .label text, #mermaid-r12m-r2 .node .label text, #mermaid-r12m-r2 .image-shape .label, #mermaid-r12m-r2 .icon-shape .label { text-anchor: middle; }
#mermaid-r12m-r2 .node .katex path { fill: rgb(0, 0, 0); stroke: rgb(0, 0, 0); stroke-width: 1px; }
#mermaid-r12m-r2 .rough-node .label, #mermaid-r12m-r2 .node .label, #mermaid-r12m-r2 .image-shape .label, #mermaid-r12m-r2 .icon-shape .label { text-align: center; }
#mermaid-r12m-r2 .node.clickable { cursor: pointer; }
#mermaid-r12m-r2 .root .anchor path { stroke-width: 0; stroke: rgb(161, 161, 161); fill: rgb(161, 161, 161) !important; }
#mermaid-r12m-r2 .arrowheadPath { fill: rgb(11, 11, 11); }
#mermaid-r12m-r2 .edgePath .path { stroke: rgb(161, 161, 161); stroke-width: 1px; }
#mermaid-r12m-r2 .flowchart-link { stroke: rgb(161, 161, 161); fill: none; }
#mermaid-r12m-r2 .edgeLabel { background-color: transparent; text-align: center; }
#mermaid-r12m-r2 .edgeLabel p { background-color: transparent; }
#mermaid-r12m-r2 .edgeLabel rect { opacity: 0.5; background-color: transparent; fill: transparent; }
#mermaid-r12m-r2 .labelBkg { background-color: rgba(0, 0, 0, 0.5); }
#mermaid-r12m-r2 .cluster rect { fill: rgb(204, 120, 92); stroke: rgb(138, 115, 107); stroke-width: 1px; }
#mermaid-r12m-r2 .cluster text { fill: rgb(51, 135, 163); }
#mermaid-r12m-r2 .cluster span { color: rgb(51, 135, 163); }
#mermaid-r12m-r2 div.mermaidTooltip { position: absolute; text-align: center; max-width: 200px; padding: 2px; font-family: "Anthropic Sans", system-ui, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 12px; background: rgb(204, 120, 92); border: 1px solid rgb(138, 115, 107); border-radius: 2px; pointer-events: none; z-index: 100; }
#mermaid-r12m-r2 .flowchartTitleText { text-anchor: middle; font-size: 18px; fill: rgb(229, 229, 229); }
#mermaid-r12m-r2 rect.text { fill: none; stroke-width: 0; }
#mermaid-r12m-r2 .icon-shape, #mermaid-r12m-r2 .image-shape { background-color: transparent; text-align: center; }
#mermaid-r12m-r2 .icon-shape p, #mermaid-r12m-r2 .image-shape p { background-color: transparent; padding: 2px; }
#mermaid-r12m-r2 .icon-shape .label rect, #mermaid-r12m-r2 .image-shape .label rect { opacity: 0.5; background-color: transparent; fill: transparent; }
#mermaid-r12m-r2 .label-icon { display: inline-block; height: 1em; overflow: visible; vertical-align: -0.125em; }
#mermaid-r12m-r2 .node .label-icon path { fill: currentcolor; stroke: revert; stroke-width: revert; }
#mermaid-r12m-r2 .node .neo-node { stroke: rgb(161, 161, 161); }
#mermaid-r12m-r2 [data-look="neo"].node rect, #mermaid-r12m-r2 [data-look="neo"].cluster rect, #mermaid-r12m-r2 [data-look="neo"].node polygon { stroke: url("#mermaid-r12m-r2-gradient"); filter: drop-shadow(rgb(185, 185, 185) 1px 2px 2px); }
#mermaid-r12m-r2 [data-look="neo"].node path { stroke: url("#mermaid-r12m-r2-gradient"); stroke-width: 1px; }
#mermaid-r12m-r2 [data-look="neo"].node .outer-path { filter: drop-shadow(rgb(185, 185, 185) 1px 2px 2px); }
#mermaid-r12m-r2 [data-look="neo"].node .neo-line path { stroke: rgb(161, 161, 161); filter: none; }
#mermaid-r12m-r2 [data-look="neo"].node circle { stroke: url("#mermaid-r12m-r2-gradient"); filter: drop-shadow(rgb(185, 185, 185) 1px 2px 2px); }
#mermaid-r12m-r2 [data-look="neo"].node circle .state-start { fill: rgb(0, 0, 0); }
#mermaid-r12m-r2 [data-look="neo"].icon-shape .icon { fill: url("#mermaid-r12m-r2-gradient"); filter: drop-shadow(rgb(185, 185, 185) 1px 2px 2px); }
#mermaid-r12m-r2 [data-look="neo"].icon-shape .icon-neo path { stroke: url("#mermaid-r12m-r2-gradient"); filter: drop-shadow(rgb(185, 185, 185) 1px 2px 2px); }
#mermaid-r12m-r2 :root { --mermaid-font-family: "Anthropic Sans",system-ui,"Segoe UI",Roboto,Helvetica,Arial,sans-serif; }NoYesNoYesNoYesStartSource folderexists?Log warningskip cleanupGet-ChildItem -File(top level only)Extension matchesAND LastWriteTimeolder than N days?SkipMove-Item to archive folderLog actionProject folderexists?Log warningskip backupCompress-Archivetimestamped .zipLog successEnd


🚀 Setup

powershell# Clone or copy the script into your own scripts folder
git clone https://github.com/yourusername/cleanup-and-backup-powershell.git
Set-Location cleanup-and-backup-powershell

# Allow locally-written scripts to run (one-time, current user only)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# If the file was downloaded (not git-cloned), clear the "from the internet" flag
Unblock-File -Path .\Cleanup-And-Backup.ps1

No external modules required — built entirely on PowerShell's standard cmdlets (Get-ChildItem, Move-Item, Compress-Archive, Get-Date).


▶️ Usage

powershell# Always preview first — no files are touched
.\Cleanup-And-Backup.ps1 -DryRun

# Run for real with default settings (Downloads, 30 days, Projects → Backups)
.\Cleanup-And-Backup.ps1

# Fully customized run
.\Cleanup-And-Backup.ps1 `
    -SourceFolder "$env:USERPROFILE\Desktop" `
    -ArchiveFolder "$env:USERPROFILE\Desktop\_archive" `
    -DaysOld 14 `
    -Extensions ".tmp", ".log", ".crdownload" `
    -ProjectFolder "$env:USERPROFILE\dev\my-project" `
    -BackupFolder "E:\Backups"


⚠️ Note the mandatory .\ prefix — PowerShell never runs a script from the current folder by filename alone, even standing inside it. This is a deliberate security default, not a bug.



Parameters

FlagDefaultDescription-SourceFolderDownloadsFolder to scan for old files-ArchiveFolderDownloads\_old_files_archiveDestination for archived files-DaysOld30Age threshold in days-Extensions.tmp .temp .log .crdownload .part"Junk" extensions to target (empty array = match all files)-ProjectFolderProjectsFolder to compress and back up-BackupFolderBackupsDestination for the .zip (local, USB, or OneDrive folder)-DryRunoffPreview actions, make no changes


⏰ Scheduling with Task Scheduler

PowerShell's equivalent of cron:

powershell$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"C:\path\to\Cleanup-And-Backup.ps1`""
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 3am

Register-ScheduledTask -TaskName "CleanupAndBackup" -Action $action -Trigger $trigger

Verify with Get-ScheduledTask -TaskName "CleanupAndBackup".


🐛 Troubleshooting

<details>
<summary><strong>❌ "running scripts is disabled on this system"</strong></summary>
<br>
Cause: Windows blocks unsigned .ps1 scripts by default — affects any PowerShell script on a fresh install, not specific to this one.

Fix:

powershellGet-ExecutionPolicy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

If downloaded rather than cloned, also clear the internet-origin flag:

powershellUnblock-File -Path .\Cleanup-And-Backup.ps1

</details>
<details>
<summary><strong>❌ Typing the script name does nothing</strong></summary>
<br>
Cause: Unlike Bash, PowerShell never executes a script from the current directory by filename alone — even standing inside that exact folder. It's an intentional security measure against a malicious script shadowing a built-in command.

Fix: always prefix with .\ or a full path:

powershell.\Cleanup-And-Backup.ps1 -DryRun

</details>
<details>
<summary><strong>❌ Setup commands accidentally end up inside the script file</strong></summary>
<br>
Cause: In editors like VS Code, it's easy to type one-off commands (folder creation, test-file setup) directly into the .ps1 file instead of the integrated terminal. They'll still "work" when you run the file, but they'll re-run on every execution — not what you want for a reusable tool.

Fix: keep one-off setup/verification commands in the terminal (Ctrl+` in VS Code); keep only the param() block, functions, and MAIN section inside the script itself.

</details>

🏗️ Design Notes


LastWriteTime is the Windows/NTFS counterpart to Linux's mtime — the reliable, portable property for file-age checks.
Get-ChildItem -File filters out directories automatically, preventing the script from ever trying to archive a live application's working folder.
Compress-Archive ships natively with PowerShell 5.1+ (default on Windows 11) — zero external dependencies.
Plain archive folder, not the Recycle Bin — keeps the script dependency-free; swap in the third-party Recycle module if true Recycle Bin integration is needed.
Timestamped backups preserve history instead of overwriting the previous .zip on each run.



📁 Project Structure

cleanup-and-backup-powershell/
├── Cleanup-And-Backup.ps1   # main script
└── README.md


📜 License

Distributed under the MIT License. Free to use, modify, and adapt.


<div align="center">
Built as a hands-on systems administration exercise, paired with the Linux/Python edition.

</div>