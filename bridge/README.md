# Bridge Scripts

The bridge is a local PowerShell worker that executes requests written to `bridge/request.txt`. Codex should not call SSH directly. Codex writes a request, waits for `bridge/status.txt`, and reads `bridge/output.txt`.

## Files

- `bridge_worker.ps1`: Long-running worker that reads requests and captures command output.
- `ensure_bridge.ps1`: Starts the scheduled bridge task if needed.
- `register_bridge_task.ps1`: Registers the visible bridge worker as a Windows Scheduled Task.
- `submit_request.ps1`: Manual helper for testing requests outside Codex.
- `clean_bridge_runtime.ps1`: Removes runtime files only.

## Runtime Status Values

- `READY`: Worker is alive and waiting.
- `RUNNING`: Worker is executing a request.
- `DONE`: Request completed with exit code `0`.
- `ERROR`: Request failed or the worker caught an error.

The bridge scripts do not inspect binary files. Keep command output concise.
