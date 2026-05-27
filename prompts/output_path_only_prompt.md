# Output Path Only Prompt

Read `AGENTS.md` first and keep auto-review mode. Use the bridge only.

The remote code already works. Only change `OUTPUT_PATH` or the equivalent output directory logic so outputs are written to `Output_Figures`.

Rules:

- Do not change data-reading logic.
- Do not change plotting logic.
- Do not change fitting, smoothing, calibration, normalization, or analysis logic.
- Create a `.bak` backup before editing the remote script.
- Run the remote script after the minimal output-path change.
- Package `Output_Figures`, the final Python code, the `.bak` file, helper `.py` files, and `run_report.txt`.
- Download and extract the package locally.
- Report only concise status, generated file names, archive paths, and traceback if any.
