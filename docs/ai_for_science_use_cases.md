# AI For Science Use Cases

This template is for data-heavy workflows where local Codex is useful for orchestration and code editing, but remote execution is the right place for data access and computation.

## Large Optical Imaging Datasets

Remote workstations often store high-resolution optical image collections near acquisition software. The remote script can batch-process the data and return only figures, summaries, and code snapshots.

## Spectral Imaging

Spectral cubes and wavelength-resolved image stacks can be large and environment-dependent. Remote Python can read the native data layout and write processed maps or spectra to `Output_Figures`.

## Electrochemical Time-Series Analysis

Long time-series files, synchronized voltage traces, and derived plots can be processed on the remote machine while Codex manages code changes and run reports.

## Microscopy Batch Processing

Batch image analysis may depend on workstation-specific libraries or local folder conventions. This bridge keeps those dependencies remote.

## Operando Spectroscopy

Operando experiments may combine spectra, time stamps, potentials, and metadata. Remote execution avoids moving large raw datasets while still making processed outputs available locally.

## Remote Workstation Python Workflows

Some teams maintain a stable remote Python environment for instruments and analysis. Codex can inspect versions, patch scripts, run analysis, and retrieve outputs without replacing that environment.

## Legacy Spyder Scripts

Existing scripts developed in Spyder can often run from the command line with small path adjustments. The recommended first change is output-path-only redirection to `Output_Figures`.

## Data-Heavy Workflows

When moving raw data locally is inefficient, keep raw files on `REMOTE_HOST`, package only processed outputs and relevant code, and archive the results locally.
