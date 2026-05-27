# Windows Setup

Use placeholders in public documentation. Put private values only in `config/config.local.json`.

## Local Windows Prerequisites

- Windows PowerShell.
- OpenSSH client.
- Access to this repository.
- A private SSH key stored under `.codex_ssh/` or another ignored private location.

Check the OpenSSH client:

```powershell
ssh -V
scp -V
```

## Remote Windows Prerequisites

- OpenSSH server enabled.
- A reachable host name such as `REMOTE_HOST`.
- A user account such as `REMOTE_USER`.
- Python installed and runnable through `REMOTE_PYTHON_COMMAND`.
- Experimental data and analysis scripts stored under `REMOTE_TARGET_DIR`.
- A transfer directory such as `REMOTE_TRANSFER_DIR`.

## SSH Key Authentication

Create or provide an SSH key outside the public repository. Store the private key in an ignored path such as:

```text
.codex_ssh/id_ed25519_remote_example
```

Install the matching public key for `REMOTE_USER` on `REMOTE_HOST`.

## Local Config

Copy the public example:

```powershell
Copy-Item .\config\config.example.json .\config\config.local.json
```

Edit `config/config.local.json` with private values:

- `local_project_root`
- `local_archive_root`
- `local_python_code_archive_root`
- `remote_host`
- `remote_user`
- `remote_python_command`
- `remote_expected_python_version`
- `remote_target_dir`
- `remote_transfer_dir`
- `ssh_key_path`
- `task_scheduler_name`

Never commit `config/config.local.json`.

## Register The Bridge Scheduled Task

Run once from the local project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\register_bridge_task.ps1
```

This creates an AtLogOn scheduled task for the current interactive user and starts a visible PowerShell bridge worker.

## Run A Bridge Check

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1
```

Expected output:

```text
BRIDGE_OK
```

or:

```text
BRIDGE_STARTED
```

## Submit The First Remote Task

Use a prompt from `prompts/`, or manually test the bridge:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\submit_request.ps1 -Command "Write-Host bridge_test"
```

For remote work, Codex should write the SSH command into `bridge/request.txt` and let the bridge worker run it.
