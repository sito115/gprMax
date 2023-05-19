clear, clc, close all
addpath(genpath(pwd))

%%
% Dialog
prompt = {'Component [Ex, Ey, Ez]', 'Cutoff Frequency', 'Threshold first non-zero value',...
          'Normalize Time? [1 or 0]', 'Normalize Frequency? [1 or 0]','load .mat file?'};
answer = inputdlg(prompt','Define Parameters',[1 150],{'Ey', '6e8', '1e-1', '0', '0','0'});

component         = answer{1};
fcut              = str2double(answer{2});
nonZeroThresh     = str2double(answer{3});
normalizationTime = str2double(answer{4});
normalizationFreq = str2double(answer{5});
isMatFile         = str2double(answer{6});

% Check for folder existance
pathRoot      = 'C:\OneDrive - Delft University of Technology'; % specific pathRoot
if exist(pathRoot,'dir')~=7
    pathRoot     = pwd;
    trdSemester  = '';
    figureFolder ='';
else
    trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
    figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';
end

% default file names
filenameArray = {'PlaceAntennas_Dist1.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist2.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist3.5m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist4.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out',...
                 'PlaceAntennas_Dist5.0m_tSim5.00e-08_eps1.00_iA1_iBH0 (2).out',...
                 'PlaceAntennas_Dist7.0m_tSim5.00e-08_eps1.00_iA1_iBH0.out'};

%% Start Skript
if ~isMatFile
    allData  = struct;
    
    answer = questdlg(['Start of the program: Which files should be selected? Pre-Selected files' filenameArray], ...
        'Question', ...
        'Manual','Default (only for Thomas)','Cancel','Manual');
    % Handle response
    switch answer
        case 'Manual'
            isManual = 1;
        case 'Default (only for Thomas)'
            isManual = 0;
            pathname        = fullfile(pathRoot, trdSemester, 'Results');   
            allData         = load_output(allData,filenameArray, pathname);
        case 'Cancel'
            return
    end
    
    %% Start Loading Data
    isFile = 1;
    while isFile == 1
        [filenameArray, pathname, check] = uigetfile([fullfile(pathRoot,trdSemester,'Results') '\*.out'],...
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
    allData     = loadedData.data;

end

plot_TimeFreqDomain(allData, component, fcut, nonZeroThresh, normalizationTime, normalizationFreq)








