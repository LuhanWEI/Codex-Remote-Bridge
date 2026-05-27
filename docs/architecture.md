# Architecture

This template separates local AI orchestration from private remote execution.

## Flow

```text
Local Codex
  -> bridge/request.txt
  -> local Bridge worker
  -> SSH/SCP
  -> remote Windows
  -> remote Python
  -> Output_Figures
  -> zip package
  -> local archive
```

## Components

`Local Codex` reads `AGENTS.md`, prompt templates, and code text. It writes remote task requests into the bridge runtime files and reads concise status output.

`bridge/request.txt` is the handoff file. It contains the command to be executed by the bridge worker.

`local Bridge worker` is a visible PowerShell process outside the Codex sandbox. It reads requests, executes them from the local project root, captures output, and writes status files.

`SSH/SCP` is used by the bridge worker for remote execution and package transfer.

`remote Windows` hosts the experimental data and the working Python environment.

`remote Python` reads remote data directly from the remote filesystem and writes processed outputs.

`Output_Figures` contains generated figures and result files. It should not contain raw experimental data unless the user explicitly chooses that behavior.

`zip package` contains `Output_Figures`, selected Python code, backup files, helper scripts, and `run_report.txt`.

`local archive` stores the downloaded package contents and a separate copy of Python code files for inspection and archiving.

## Design Principle

The bridge keeps private access outside Codex. Codex should see only concise text output such as status, file names, file sizes, archive paths, Python version, and tracebacks.
