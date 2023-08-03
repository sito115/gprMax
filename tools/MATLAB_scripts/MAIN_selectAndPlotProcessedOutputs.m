clear, clc, close all
addpath(genpath(pwd))

% Script to load parameters for the function plot_TimeFreqDomain.m which
% displays all individual traces of an .out file with additional
% "USER-Options" in the menu

%%
component         = 'Ey';
fcut              = 500;
isMatFile         = false;

% Check for folder existance
pathRoot      = 'C:\OneDrive - Delft University of Technology'; % specific pathRoot
if exist(pathRoot,'dir')~=7
    pathRoot     = pwd;
    trdSemester  = '';
    figureFolder ='';
else
    trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax';
    figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';
end

% default file names
filenameArray = {'Place here your favorite files'};

%% Start Skript
if ~isMatFile
    allData  = struct;
    
    answer = questdlg(['Start of the program: Which files should be selected? Pre-Selected files' filenameArray], ...
        'Question', ...
        'Manual','Default','Cancel','Manual');
    % Handle response
    switch answer
        case 'Manual'
            isManual = 1;
        case 'Default'
            isManual = 0;
            pathname        = fullfile(pathRoot, trdSemester, 'ProcessedFiles');   
            allData         = load_output(allData,filenameArray, pathname);
        case 'Cancel'
            return
    end
    
    %% Start Loading Data
    isFile = 1;
    while isFile == 1
        [filenameArray, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester,'ProcessedFiles') '\*.out'],...
                                    'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
        
        if check == 0   % user pressed cancel
            break
        end
    
        allData = load_output(allData,filenameArray, pathname);
    
        answer = questdlg('Would you like to chose more files?', ...
	        'Question', ...
	        'Yes','No','Cancel','No');
        % Handle response
        switch answer
            case 'Yes'
                isFile = 1;
            case 'No'
                isFile = 0;
            case 'Cancel'
                return
        end
    end

else
    % load allData
    [file, path] = uigetfile([fullfile(pathRoot,trdSemester,'Results') '\*.mat'], 'Select a .mat file',...
        'MultiSelect','off');
    loadedData = load(fullfile(path, file)); % specify is necessary
    allData     = loadedData.DiffStruct;

end

%% Call main function
plot_TimeFreqDomain(allData, component, fcut)








