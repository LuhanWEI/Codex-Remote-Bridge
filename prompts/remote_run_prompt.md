# Remote Run Prompt

Read `AGENTS.md` first and keep auto-review mode. Use the local bridge only. Do not execute SSH directly, do not read private keys, and do not use `ssh-agent` directly.

## Placeholders

- Remote target directory: `{{REMOTE_TARGET_DIR}}`
- Remote output directory: `{{REMOTE_OUTPUT_DIR}}`
- Local archive root: `{{LOCAL_ARCHIVE_ROOT}}`
- Local code archive root: `{{LOCAL_CODE_ARCHIVE_ROOT}}`
- Expected Python version: `{{EXPECTED_PYTHON_VERSION}}`
- Task description: `{{TASK_DESCRIPTION}}`

## Required Workflow

1. Check the bridge with:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1
   ```

2. Use the bridge only by writing commands into `bridge/request.txt`.
3. Check the remote hostname through the bridge.
4. Confirm the remote Python version matches `{{EXPECTED_PYTHON_VERSION}}` or report the mismatch.
5. Inspect the remote target directory by listing concise file names only.
6. Identify the main Python script.
7. Create a `.bak` backup before modifying any remote code.
8. If an output-path change is needed, make only the minimal output directory change to `{{REMOTE_OUTPUT_DIR}}`.
9. Do not change data-reading, plotting, fitting, smoothing, calibration, or analysis logic unless an actual error requires it.
10. Run remote Python on the remote computer.
11. Do not inspect images, raw data, TIFF files, large CSV files, binary files, or base64 content.
12. Package `Output_Figures`, final Python code, backup files, helper scripts, and `run_report.txt`.
13. Download and extract the package into `{{LOCAL_ARCHIVE_ROOT}}`.
14. Copy Python code files into `{{LOCAL_CODE_ARCHIVE_ROOT}}`.

Return concise status only: bridge status, hostname, Python version, selected script, generated file names, local archive path, local code archive path, and traceback if any.
