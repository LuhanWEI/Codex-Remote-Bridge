# Token Cost

Remote computation does not directly consume model tokens. Running Python on `REMOTE_HOST` uses remote compute resources, not model context.

File transfer does not directly consume model tokens. SCP downloads and zip extraction are normal system operations.

Token usage comes from text that Codex reads or writes:

- User prompts.
- `AGENTS.md`.
- Prompt templates.
- Code text.
- Command outputs.
- Tracebacks.
- Final reports.

Generated images do not consume tokens if Codex does not read or analyze them. The same applies to raw binary data, TIFF stacks, and large CSV files.

## Cost-Control Practices

- Suppress verbose logs when possible.
- Return concise status lines.
- Return traceback text only when needed.
- List generated file names instead of reading generated files.
- Avoid base64 content in bridge output.
- Avoid printing large arrays, tables, or raw data samples.
