# Security

## Never Commit Private Material

Do not commit:

- Private SSH keys.
- `config/config.local.json`.
- Raw experimental data.
- Generated figures or result archives.
- Private usernames, hostnames, paths, project names, sample names, or institution names.

The `.gitignore` file is configured to ignore common private files and generated outputs, but users should still review changes before publishing.

## Revoke An SSH Key

To revoke a key, remove the matching public key from the remote user's authorized key configuration on `REMOTE_HOST`. Then delete or archive the local private key from `.codex_ssh/` and replace it with a new key pair if needed.

## Why Codex Should Not Read Binary Files By Default

Binary files, generated images, TIFF stacks, large CSV files, and base64 content can be large, expensive to summarize, and may contain sensitive experimental information. Codex should usually report only file names, sizes, paths, and tracebacks.

## Why The Bridge Is Needed

Sandboxed Codex modes should not directly access private keys or run remote commands. The bridge worker runs outside the sandbox and acts as an auditable boundary. Codex writes a request, waits for status, and reads concise text output.

## Safe Publishing Checklist

- Confirm `config/config.local.json` is absent.
- Confirm `.codex_ssh/` is absent.
- Confirm no raw data or generated result folders are present.
- Search for private hostnames, usernames, local paths, institution names, experiment names, and sample names.
- Keep all docs and examples placeholder-based.
