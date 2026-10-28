# GN-PTC

MATLAB package for QGS feasibility sampling and flat-start comparison with Ipopt/MA57.

During manuscript submission and review, the solvers in `algorithms/pseudotran` are distributed as MATLAB P-code (`.p`). Their corresponding source code (`.m`) will be released after the paper is formally published.

## Entry points

Both entry points remain editable. Internal solvers, model routines and batch helpers are provided as P-code.

| Entry | Purpose |
| --- | --- |
| `SEMs_AS_test.m` | Sample the `case9mod` feasible region from 1000 random initial points and plot the `Pg1`–`Pg2` projection in MW. |
| `main_matpower_flat.m` | Compare PTC, GN, GN with hysteresis and fallback, and Ipopt/MA57 on 72 MATPOWER cases using shared flat starts. |

Run MATLAB from this repository directory.

### case9mod sampling

```matlab
SEMs_AS_test
```

The default solver is `pseudotran_qgs_gn_filter_hyst`. Progress, constraint residuals and solve times are displayed. The figure and endpoint arrays remain in MATLAB; this entry creates no result files. See [SOLVERS.txt](SOLVERS.txt) for the eight available solvers.

### MATPOWER flat-start comparison

```matlab
[wide, summary, files] = main_matpower_flat;
```

The four methods are `PTC`, `GN`, `GN_hyst_back` and `Ipopt_MA57`: 72 cases × one flat start × four methods = 288 solves. The improved QGS arm uses `pseudotran_qgs_gn_filter_hyst_back`. All methods receive the same initial vector for each case. Ipopt uses a constant-zero objective to find feasible points.

For a smaller run:

```matlab
cfg = struct();
cfg.CaseNames = {'case9', 'case14'};
[wide, summary, files] = main_matpower_flat(cfg);
```

Results are saved under `results/matpower_flat`, including comparison tables, solver-time plots and endpoint-violation plots. Generated results are ignored by Git. See [FLAT_BENCHMARK.txt](FLAT_BENCHMARK.txt) for options and [MATPOWER_CASES.txt](MATPOWER_CASES.txt) for the case list.

## Environment

The package was checked with MATLAB R2025b on an Apple Silicon Mac. The bundled Ipopt MEX interface targets that platform and links to the existing Homebrew Ipopt installation under `/opt/homebrew/opt/ipopt/lib`.

MA57 uses an existing local HSL library. Set `cfg.HslLibrary` or the `QGS_HSL_LIBRARY` environment variable when automatic detection does not find it. The HSL library is supplied separately, following the [upstream HSL notice](licenses/mexIPOPT_HSL.txt). The flat-start benchmark is configured for this Mac environment; Windows has not been tested.

## Contents and validation

- Eight protected QGS/PTC solvers, two editable entry points and protected model/batch helpers.
- `data/case9mod.p` for random-start sampling; 72 MATPOWER cases stored as MAT data in `benchmark_cases`.
- Solver-only timing and independent endpoint constraint checks. QGS equilibrium alone does not establish feasibility.
- A three-case, four-method workflow check verified shared starts, table export and both comparison plots. A separate solve confirmed that the packaged interface uses MA57. The complete 72-case batch was not rerun for packaging.

The existing `GN-PTC_vs_Ipopt_MA57.xlsx` comparison workbook is retained. Third-party license notices and corresponding MATPOWER source archives are in [licenses](licenses). See [BUILD_INFO.txt](BUILD_INFO.txt) for the protected-file manifest.
