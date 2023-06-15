% plot_Bscan.m
clc, clear ,close all
%% MAIN
p          = mfilename('fullpath');
script_dir = fileparts(p);
addpath(genpath(script_dir));


%% Plotting Parameters
isNormalize = 1;     % normalize traces

component   = 'Ey';     % which component?
isSave      = false;

% call main function
isGain = 1;
filename = [];%'C:\OneDrive - Delft University of Technology\3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles\3_IncreasingGradient\HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.out';
data = plt_BScan(isNormalize, component,filename);

%% Functions
