function [wide,summary,files]=main_matpower_flat(usercfg)
%MAIN_MATPOWER_FLAT Compare QGS and Ipopt/MA57 on flat starts.

root=fileparts(mfilename('fullpath'));
oldpwd=pwd; cleanup=onCleanup(@()cd(oldpwd));
cd(root);
addpath(root);
setup_qgs_paths;
cfg=struct('DataDir',fullfile(root,'benchmark_cases'), ...
    'OutputDir',fullfile(root,'results','matpower_flat'), ...
    'StartModes',{{'flat'}},'MakePlots',true,'PlotVisible',true);
if nargin>=1 && ~isempty(usercfg)
    keys=fieldnames(usercfg);
    for k=1:numel(keys), cfg.(keys{k})=usercfg.(keys{k}); end
end
assert(isequal(cellstr(string(cfg.StartModes)),{'flat'}), ...
    'QGSFlat:StartMode','This entry uses flat starts only.');
[wide,summary,files]=main_compare_qgs_ipopt(cfg);
end
