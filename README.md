# Remote Codex Bridge

**Run remote science workflows from Codex auto-review mode.** This template is designed so Codex can guide a remote computer through SSH-mediated tasks without requiring Codex to run in full-access mode. Codex stays in its safer auto-review workflow, writes auditable requests to a local bridge, and the bridge worker performs the approved SSH/SCP operations outside the sandbox.

This project provides a reusable workflow for direct remote data processing. It allows local Codex to send engineering task instructions to a remote computer through an SSH bridge. The remote computer reads its own experimental data, runs Python-based data processing and analysis, generates figures or result files, and sends the processed outputs back to the local computer for review and archiving. The method is useful for AI for Science workflows, especially when experimental data are too large or too environment-dependent to move locally, while the user still wants to use Codex for vibe coding, remote task orchestration, code modification, analysis automation, and result retrieval.

## What Problem This Solves

Many experimental workflows keep data on a workstation or server because the files are large, the data path is shared with instruments, or the analysis depends on a carefully maintained remote Python environment. This template lets local Codex orchestrate the engineering workflow while the data and computation stay remote.

Use it when you want Codex to help with:

- Selecting or editing Python analysis scripts.
- Launching remote runs through a controlled bridge.
- Redirecting outputs to a standard `Output_Figures` directory.
- Packaging figures, result files, reports, and relevant code.
- Downloading a compact result archive for local inspection.

## Why Not Run Everything Locally

Running locally can be inefficient or unreliable when raw data are too large to transfer, remote instrument paths are required, or the remote workstation has the exact package versions used by existing analysis scripts. This workflow keeps raw data near the instruments and moves only processed outputs and code snapshots back to the local machine.

## Why A Bridge Is Needed

Sandboxed Codex modes should not directly access private keys, execute SSH commands, or read remote files. This bridge makes remote execution possible while keeping Codex in auto-review mode, so users do not need to grant full-access permissions just to orchestrate remote analysis. The bridge separates responsibilities:

- Codex writes a plain-text request to `bridge/request.txt`.
- A local PowerShell worker running outside the sandbox executes the request.
- Codex reads concise status and output files after the worker finishes.

This keeps the orchestration auditable while avoiding direct key handling inside Codex.

## Typical AI For Science Examples

- Optical or spectral imaging.
- Electrochemical data processing.
- Microscopy batch analysis.
- Operando spectroscopy workflows.
- Large TIFF or CSV experimental datasets.
- Legacy Spyder or workstation Python workflows.

## Quick Start

1. Copy `config/config.example.json` to `config/config.local.json`.
2. Replace every placeholder value in `config/config.local.json` with local private values.
3. Confirm `config/config.local.json` and `.codex_ssh/` are ignored by git.
4. Register the bridge task once:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\register_bridge_task.ps1
   ```

5. Check the bridge:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1
   ```

6. Use the prompt templates in `prompts/` with Codex.

## Repository Structure

```text
config/      Public example configuration.
bridge/      Local bridge worker and helper scripts.
scripts/     Packaging, download, and inspection helpers.
prompts/     Reusable Codex task prompts.
docs/        Architecture, setup, security, token cost, and troubleshooting notes.
templates/   Reusable run report template.
```

## Security Warning

Never commit private SSH keys, `config/config.local.json`, raw data, generated result archives, or private paths. Use placeholders in public docs and templates. Codex should report concise text output only and should not inspect binary files, generated images, TIFF stacks, large CSV files, or base64 content unless explicitly requested.

## Daily Workflow

1. Ask Codex to read `AGENTS.md`.
2. Codex checks the bridge with `bridge/ensure_bridge.ps1`.
3. Codex writes a remote task command into `bridge/request.txt`.
4. The bridge worker runs the command through SSH or SCP.
5. Remote Python processes remote data and writes outputs to `Output_Figures`.
6. The remote computer creates a timestamped zip package.
7. The local computer downloads and extracts the package.
8. Codex reports status, selected script, Python version, generated file names, archive paths, and traceback if any.

## Token Cost Notes

Remote computation and file transfer do not directly consume model tokens. Token use mainly comes from prompts, documentation, code text, command outputs, tracebacks, and final reports. Keep outputs concise, suppress verbose logs, and list file names instead of reading generated files.

## Troubleshooting Overview

See `docs/troubleshooting.md` for common failures including missing bridge tasks, stale runtime files, SSH permission errors, remote Python version issues, package creation failures, SCP download failures, and unexpectedly high token usage.
