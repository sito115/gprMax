% Display an single .out File from gprMax as B-scan
% You can perform multiple analysis tools in the figure under
% "USER-Options"
% such as: Save figure as pdf,Velocity estimation, NMO velocity estimation,
% Find peak amplitudes in time window, display individual traces,
% difference 

clc, clear,close all
% get current path and add all subfolders
p          = mfilename('fullpath');
script_dir = fileparts(p);
addpath(genpath(script_dir));


% Define parameters for display
isNormalize = true;     % normalize traces
component   = 'Ey';  % which component?
isSave      = false;     % automatically save
isGain      = true;     % apply Gain function [1 0]
filename    = [];    % file name as absolute path, if empty you can select it later via GUI
%% call main function
data = plt_BScan(isNormalize, component,filename,isGain,isSave);

