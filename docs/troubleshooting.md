# Troubleshooting

## Bridge Task Not Found

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\register_bridge_task.ps1
```

Then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1
```

## Bridge Window Not Open

Run `bridge/ensure_bridge.ps1`. If it cannot start the scheduled task, register the task again. Confirm the current user is allowed to run scheduled tasks interactively.

## bridge/status.txt Stuck At RUNNING

Check `bridge/heartbeat.txt`. If the heartbeat is old, close stale bridge windows and run `bridge/clean_bridge_runtime.ps1`, then start the bridge again. If the heartbeat is fresh, the remote command may still be running.

## SSH Permission Denied

Check:

- `remote_user`
- `remote_host`
- `ssh_key_path`
- Remote authorized key configuration
- Remote OpenSSH server status

Do not print private key contents.

## Codex Accidentally Tried Direct SSH

Stop and return to `AGENTS.md`. Codex must use the bridge only. Put the SSH command into `bridge/request.txt` and let the bridge worker execute it.

## Remote Path Contains Spaces

Prefer remote transfer paths without spaces. If a target path contains spaces, quote it carefully in PowerShell and SSH commands. Keep zip file names space-free.

## Python Not Found

Check `remote_python_command` in `config/config.local.json`. Run a bridge command that prints:

```text
REMOTE_PYTHON_COMMAND --version
```

Report only concise output.

## Spyder Works But Command-Line Python Fails

Spyder may use a different environment than the command line. Find the Python executable used by Spyder and set `remote_python_command` to that executable path in private local config.

## Remote Package Zip Not Created

Check whether:

- `REMOTE_TRANSFER_DIR` exists or can be created.
- `Output_Figures` exists.
- The selected main Python script exists.
- `Compress-Archive` can write to the transfer directory.

Return only the error text and relevant file names.

## SCP Download Fails

Check:

- The remote zip path printed by the packaging script.
- SSH key path.
- Remote user and host.
- Local archive directory permissions.

Do not download raw data unless explicitly requested.

## Token Usage Unexpectedly High

Reduce command output. Avoid printing raw arrays, large tables, base64 strings, image metadata dumps, and large trace logs. Ask Codex to return only status, traceback if any, and final file lists.
