function [wide,summary,files]=main_matpower_flat(usercfg)
%MAIN_MATPOWER_FLAT Compare QGS and Ipopt/MA57 on flat starts.
% usercfg overrides defaults; CaseNames={} runs all 72 cases.
% Example: main_matpower_flat(struct('CaseNames',{{'case9','case14'}})).
% SolverOptions sets QGS budgets; IpoptMaxIter/IpoptMaxTime set Ipopt limits.
% HslLibrary selects the MA57 library; WriteExcel controls workbook output.
% See FLAT_BENCHMARK.txt for defaults and solver limit handling.

root=fileparts(mfilename('fullpath'));
oldpwd=pwd; cleanup=onCleanup(@()cd(oldpwd));
cd(root);
addpath(root);
setup_qgs_paths;
cfg=struct('DataDir',fullfile(root,'benchmark_cases'), ... % Input case folder.
    'OutputDir',fullfile(root,'results','matpower_flat'), ... % Parent folder for run results.
    'StartModes',{{'flat'}},'MakePlots',true,'PlotVisible',true); % Flat starts; save and show plots.
if nargin>=1 && ~isempty(usercfg)
    keys=fieldnames(usercfg);
    for k=1:numel(keys), cfg.(keys{k})=usercfg.(keys{k}); end
end
assert(isequal(cellstr(string(cfg.StartModes)),{'flat'}), ...
    'QGSFlat:StartMode','This entry uses flat starts only.');
[wide,summary,files]=main_compare_qgs_ipopt(cfg);
end
