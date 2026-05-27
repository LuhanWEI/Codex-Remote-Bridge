# Bridge Check Prompt

Read `AGENTS.md` first and keep auto-review mode.

Check the local bridge only:

1. Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\bridge\ensure_bridge.ps1`.
2. Send a short hostname command through the bridge.
3. Wait for `bridge/status.txt` to become `DONE` or `ERROR`.
4. Read `bridge/output.txt`.

Report only bridge status, hostname output, and any concise error text. Do not execute SSH directly from Codex.
