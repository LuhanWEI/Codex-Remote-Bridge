# AGENTS.md

Codex must follow these rules in this repository.

## Required First Step

Always read this file first. Keep auto-review mode unless the user explicitly changes it.

## Bridge-Only Remote Access

- Do not execute SSH directly from Codex.
- Do not read private SSH keys.
- Do not use `ssh-agent` directly.
- Use the local bridge only.
- Before any remote operation, run:

  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1
  ```

- To run remote commands, write commands into `bridge/request.txt`.
- Wait for `bridge/status.txt` to become `DONE` or `ERROR`.
- Read `bridge/output.txt`.

## Data Handling

- Remote data processing must run on the remote computer.
- Do not move raw experimental data to local unless explicitly requested.
- Do not read remote raw data unless strictly necessary.
- Do not read generated images, binary files, TIFF files, large CSV files, or base64 content.
- Only list file names, file sizes, archive paths, concise command outputs, and traceback if any.

## Code Modification Rules

- For output redirection tasks, only change `OUTPUT_PATH` or the equivalent output directory logic.
- Do not change data-reading, plotting, fitting, smoothing, calibration, or analysis logic unless an actual error requires it.
- Before modifying any remote code file, create a `.bak` backup.

## Required Completion

After remote execution, package `Output_Figures` and Python code files, download them locally, extract them, and report the local archive path.
