%SEMS_AS_TEST Sample case9mod feasible endpoints.
clc
clear global
clear

package_root = fileparts(mfilename('fullpath'));
cd(package_root);
addpath(package_root);
setup_case9mod_paths;

%% Settings
Npnts = 1000;                      % Number of random initial points.
random_seed = 20260914;             % Seed for repeatable initial points.
solver_name = 'pseudotran_qgs_gn_filter_hyst'; % Solver name; see SOLVERS.txt.
epsilon = 1e-6;                     % Solver stopping tolerance.
epsod = 2e-4;                       % Constraint violation threshold for feasibility.
rng(random_seed, 'twister');

global Ai Ae bi be gh_fcn hess_fcn nb nl ng nl2 tout
CASE_DEFINE;
assert(strcmp(casename, 'case9mod'), 'QGS:Case', 'This package only runs case9mod.');
assert(nx == 2*nb + 2*ng && ng >= 2, 'QGS:Dimensions', 'Unexpected variable layout.');
solver = str2func(solver_name);
assert(strcmp(fileparts(which(solver_name)), ...
    fullfile(package_root, 'algorithms', 'pseudotran')), ...
    'QGS:SolverPath', 'Select a solver inside this package/algorithms/pseudotran.');

FSEMs = [];
DSEMs = [];
SolveTime = zeros(Npnts, 1);         % Solver calls (s).
PointTime = zeros(Npnts, 1);         % Full point processing (s).
Gmax_all = inf(Npnts, 1);
Hmax_all = inf(Npnts, 1);
Feasible = false(Npnts, 1);
TimeSpd = 0;
fprintf('-------Start QGS: %s, solver: %s, random points: %d\n', ...
    casename, solver_name, Npnts);
total_timer = tic;

%% Random starts and endpoint validation
for j = 1:Npnts
    tper = tic;
    tout = [];

    theta = zeros(nb, 1);
    a = uu(nb+1:end) - ll(nb+1:end);
    b = ll(nb+1:end);
    VPQ = rand(nx-nb, 1);
    VPQ = a .* VPQ + b;
    y0 = [theta; VPQ];

    QGS = odefun(0, y0);
    disp('PTC is in operation...')
    tspan_PTC = [0, Inf];
    vectao_k = [1e-2; 1e-2];
    Numvectao_k = size(vectao_k, 1);
    ebclong_q = (sum(log10(vectao_k))/Numvectao_k + min(log10(vectao_k))) / 2;
    ebclong = 10^ebclong_q;
    norm_f = norm(QGS);
    inistep_h = 10 * sqrt(ebclong) / max(norm_f, realmin);

    solve_timer = tic;
    [TOUT, YOUT, Dxn] = solver('odefun', tspan_PTC, y0, inistep_h, epsilon);
    SolveTime(j) = toc(solve_timer);

    Yend = YOUT(end, :)';
    QGS = odefun(0, Yend);
    QGSmax = max(abs(QGS));

    [G, H] = ghfun(Yend);
    G_max = max([0; abs(G)]);
    H_max = max([0; H]);
    H_VIO = max(G_max, H_max);
    Gmax_all(j) = G_max;
    Hmax_all(j) = H_max;
    finite_endpoint = all(isfinite([Yend; G; H; QGS]));
    Feasible(j) = finite_endpoint && H_VIO < epsod;

    if Feasible(j)
        FSEMs = [FSEMs, [H_VIO; QGSmax; Yend]];
        status_text = 'Feasible solution!';
    else
        DSEMs = [DSEMs, [H_VIO; QGSmax; Yend]];
        status_text = 'Infeasible solution!';
    end
    PointTime(j) = toc(tper);
    fprintf(['Iteration:%4d/%d  Solve:%8.4fs  Time:%8.4fs  %s  ' ...
        'max|G|=%.3e  max(H,0)=%.3e  QGS=%.3e\n'], ...
        j, Npnts, SolveTime(j), PointTime(j), status_text, G_max, H_max, QGSmax);
end

TotalTime = toc(total_timer);
TimeSpd = sum(SolveTime);

%% Pg1-Pg2 projection in MW
pg1_row = 2 + vv.i1.Pg;
pg2_row = pg1_row + 1;
FeasibleFigure = figure('Color', 'w', 'Name', 'case9mod: Pg1-Pg2');
if ~isempty(FSEMs)
    Pg1_MW = FSEMs(pg1_row, :) * baseMVA;
    Pg2_MW = FSEMs(pg2_row, :) * baseMVA;
    plot(Pg1_MW, Pg2_MW, ...
        '.', 'Color', [0, 0.60, 0.75], 'MarkerSize', 9);
    pg1_padding = max(1, 0.05 * (max(Pg1_MW) - min(Pg1_MW)));
    pg2_padding = max(1, 0.05 * (max(Pg2_MW) - min(Pg2_MW)));
    xlim([min(Pg1_MW)-pg1_padding, max(Pg1_MW)+pg1_padding]);
    ylim([min(Pg2_MW)-pg2_padding, max(Pg2_MW)+pg2_padding]);
else
    plot(NaN, NaN, '.');
    xlim([ll(vv.i1.Pg), uu(vv.i1.Pg)] * baseMVA);
    ylim([ll(vv.i1.Pg+1), uu(vv.i1.Pg+1)] * baseMVA);
    warning('QGS:NoFeasiblePoints', 'No feasible endpoints at the selected tolerance.');
end
xlabel('P_{g1} (MW)');
ylabel('P_{g2} (MW)');
title(sprintf('case9mod: feasible endpoints (%d / %d random starts)', ...
    size(FSEMs, 2), Npnts));
grid on;
box on;
drawnow;

fprintf('\nTotal random points: %d\n', Npnts);
fprintf('Feasible: %d  Infeasible: %d  Tolerance: %.1e\n', ...
    size(FSEMs, 2), size(DSEMs, 2), epsod);
fprintf('Total solver time: %10.6fs\n', TimeSpd);
fprintf('Mean solver time:  %10.6fs/point\n', mean(SolveTime));
fprintf('Total loop time:   %10.6fs\n', TotalTime);
fprintf('-------End of QGS computation: %d SEM endpoints obtained!\n', Npnts);
