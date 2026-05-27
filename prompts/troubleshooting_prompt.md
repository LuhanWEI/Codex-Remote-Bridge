# Troubleshooting Prompt

Read `AGENTS.md` first and keep auto-review mode. Use the bridge only. Do not execute SSH directly from Codex.

Debug bridge, SSH, Python, or packaging failures without reading raw data, images, TIFF files, large CSV files, binary files, or base64 content.

Check only concise text signals:

- `bridge/status.txt`
- `bridge/output.txt`
- `bridge/pid.txt`
- `bridge/heartbeat.txt`
- Remote hostname
- Remote Python version
- Remote working directory
- Names and sizes of relevant scripts and package files
- Traceback text if any

If the issue is a script failure, identify the failing file and line number from the traceback. Do not inspect generated figures or raw experimental files unless the user explicitly requests it.
