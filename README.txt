QGS-PTC-GN: case9mod feasibility sampling

Run in MATLAB:

    cd('D:\OPF\QGS-PTC-GN');
    SEMs_AS_test

Keep the folder structure intact. Paths are resolved from this package.
For the 72-case MATPOWER flat-start comparison with Ipopt/MA57, run
main_matpower_flat. See FLAT_BENCHMARK.txt for options and local dependencies.

Settings
    1000 random starts; seed 20260914.
    Zero voltage angles; Vm, Pg and Qg sampled within the model bounds.
    Default solver: pseudotran_qgs_gn_filter_hyst. Set solver_name to any name in SOLVERS.txt.
    QGS tolerance: 1e-6. Physical feasibility tolerance: 2e-4.

Files
    SEMs_AS_test.m              Entry script and settings
    algorithms/pseudotran/*.p   Eight protected solvers
    algorithms/*.p             Protected QGS model and derivatives
    data/case9mod.p             The only case
    matpower4.1/                Required MATPOWER subset
    licenses/                  MATPOWER license and source archive
    BUILD_INFO.txt             Build environment and protected-file manifest
    main_matpower_flat.m       Editable flat-start QGS/Ipopt comparison entry
    main/*.p, utils/*.p        Protected batch and plotting helpers
    benchmark_cases/*.mat      Historical 72-case MATPOWER benchmark set
    third_party/ipopt/maca64/  Ipopt interface for the current Mac installation

Results
    The figure shows feasible endpoint projections onto Pg1-Pg2 in MW.
    It is a sample of the feasible region, not a complete boundary.
    Feasibility requires finite values and both equality and inequality
    violations below 2e-4.
    FSEMs and DSEMs store [violation; QGS residual; state] in each column.
    SolveTime records solver calls; PointTime includes initialization and
    validation. TimeSpd sums SolveTime. TotalTime covers the sampling loop,
    excluding model setup and plotting. All times are in seconds.
    Progress, residuals and timing are printed to the command window.
    SEMs_AS_test creates no result files or output directories.
    The flat-start benchmark saves tables and figures as described above.

Requirements
    MATLAB R2016b or later is recommended. Built and checked with MATLAB
    R2025b on macOS using R2007b P-code format. Windows testing is pending.
    The eight solvers need no additional toolboxes, Ipopt or MA57.
    This package uses the active-set odefun; ExplicitTerms extensions and
    squared-slack callbacks are outside its scope.

Code availability
    During the manuscript submission and review stage, the solvers in
    algorithms/pseudotran are distributed as MATLAB P-code (.p); their
    corresponding source code (.m) will be released after the paper is
    formally published.
