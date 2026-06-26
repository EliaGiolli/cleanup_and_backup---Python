<div align="center">

# 🗂️🪟🐧 Cleanup & Backup — Cross-Platform Sysadmin Exercise

### The same automation task, built twice: Bash/Python on Linux, and native PowerShell on Windows 11

![Python](https://img.shields.io/badge/python-3.8%2B-blue?logo=python&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Ubuntu-E95420?logo=ubuntu&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-11-0078D6?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

---

## 📖 What's in this repo

A small filesystem-hygiene-and-backup tool, intentionally implemented **twice** — once for each major desktop OS a sysadmin/help-desk professional is expected to support:

```
.
├── linux/        → cleanup_and_backup.py   (Bash + Python, Ubuntu)
├── windows/      → Cleanup-And-Backup.ps1  (PowerShell, Windows 11)
└── README.md     → you are here
```

Each subfolder has its own detailed README covering installation, usage, CLI flags, and a real troubleshooting log from development. **This root README explains the bigger picture: why the exercise exists, and why doing it on both platforms — not just one — is the point.**

| | Linux Edition | Windows Edition |
|---|---|---|
| Language | Python 3 (stdlib only) | PowerShell 5.1+ |
| Docs | [`linux/README.md`](./linux/README.md) | [`windows/README.md`](./windows/README.md) |
| Run with | `python3 cleanup_and_backup.py --dry-run` | `.\Cleanup-And-Backup.ps1 -DryRun` |

---

## 🎯 The original brief

> *Un classico compito da amministratore di sistema: tenere pulita la macchina e mettere al sicuro i file importanti.*
> *Lo script scansiona la cartella dei Download o del Desktop, sposta i file temporanei più vecchi di X giorni in un archivio, ed effettua una copia compressa (.zip) della cartella di script/progetti su una directory di backup.*

In short: **scan → filter by age → archive**, plus **compress → store**. Two everyday sysadmin duties, distilled into something small enough to build in an afternoon but real enough to actually run on a schedule.

---

## 🤔 Why this exercise matters for a junior sysadmin

It's tempting to treat a script like this as a toy. It isn't — and here's specifically why it earns a place in a portfolio:

- **It's the literal job, in miniature.** Disk-space cleanup and scheduled backups aren't hypothetical — they're recurring tickets at every help desk, and usually the first automation task a junior admin gets handed. Building it from scratch, rather than copy-pasting a finished tool, forces an understanding of *why* each step exists, not just that it works.
- **File-age logic is a fundamental, not a detail.** Knowing the difference between modification time and creation time — and that they behave differently across filesystems and operating systems — is what separates "ran a command someone gave me" from "understands what the command is actually doing."
- **Backup logic teaches you to think about failure, not just success.** Timestamped, non-destructive archives; verifying a `.zip`'s contents instead of trusting that it exists; logging every action — these habits are what stop a 3 AM scheduled job from quietly destroying data for three weeks before anyone notices.
- **Doing it twice, cross-platform, is the real lesson.** Most IT environments support both Linux and Windows, not just one. Re-implementing identical logic in Bash/Python and PowerShell forces you to recognize which problems are *universal* (how do I know a file is old? how do I avoid destructive deletion? how do I make this restartable and idempotent?) versus which are *platform plumbing* (the file-age property's name, the compression cmdlet, the script-execution security model). That distinction is exactly what makes someone useful across a heterogeneous environment instead of a one-OS specialist.
- **The troubleshooting *is* the curriculum.** Every bug hit during development — a file landing inside `venv/` instead of the project root, a one-character typo silently creating the wrong folder, Windows' execution-policy security wall, PowerShell's mandatory `.\` prefix, mixing one-off setup commands into a reusable script — is preserved in each subfolder's README. Reading (or living through) those is arguably more valuable than the finished code: real sysadmin work is mostly diagnosing why something *that should obviously work* didn't.

---

## 🔁 The same problem, two platforms — concept mapping

| Concept | Linux / Python | Windows / PowerShell |
|---|---|---|
| File age check | `file.stat().st_mtime` | `(Get-Item $file).LastWriteTime` |
| Skip directories | `if item.is_dir(): continue` | `Get-ChildItem -File` |
| Move file safely | `shutil.move()` | `Move-Item` |
| Compress a folder | `zipfile.ZipFile(..., ZIP_DEFLATED)` | `Compress-Archive` |
| Logging | `logging` module → file + console | `Add-Content` + `Write-Host` |
| Preview mode | `--dry-run` flag (`argparse`) | `-DryRun` switch (`[CmdletBinding()]`) |
| Scheduling | `cron` / `crontab -e` | Task Scheduler / `Register-ScheduledTask` |
| Security friction encountered | IDE (`venv`) nesting confusion | Execution Policy + mandatory `.\` prefix |

Same underlying engineering decisions, different vocabulary. That's the transferable skill.

---

## 🧠 Skills this exercise actually demonstrates

- Filesystem traversal and safe, non-destructive file operations
- Date/time-based logic and its OS-level quirks (mtime vs. creation time, filesystem differences)
- Backup strategy fundamentals: compression, timestamping, integrity verification
- Defensive scripting: dry-run modes, logging, collision handling
- CLI design: configurable, parameterized tools instead of hardcoded scripts
- Task automation/scheduling (`cron` and Task Scheduler)
- Methodical debugging: `pwd`/`ls`/`find` and their Windows equivalents, reading error output literally instead of guessing
- Cross-platform fluency — recognizing what's portable logic vs. OS-specific plumbing

---

## 🚀 Getting started

Pick your platform and head to its README for full setup, usage, and the complete troubleshooting log:

- 🐧 **[Linux / Python edition →](./linux/README.md)**
- 🪟 **[Windows / PowerShell edition →](./windows/README.md)**

---

## 📜 License

Distributed under the MIT License. Free to use, modify, and adapt — built as a learning exercise, shared in case it helps the next person learning the same fundamentals.

---

<div align="center">

*Two scripts, one set of fundamentals: filesystem hygiene, file-age logic, and backup discipline — the foundation of help desk and sysadmin work, on whichever OS the ticket happens to land on.*

</div>