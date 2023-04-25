clear, close all

%% Parameters
cLight = 299792458; %3e8; %299792458; %[m/S];
fs = 16;
ms = 150;
component = 'Ex';
threshExpo = [-3,-2];
thresholds = 10.^threshExpo;
mkrs = {'o', 'diamond', 'square', '^', 'v', 'pentagram', 'hexagram','<','>'}.';
alpha = 0.7;
distance2plot = 5;

%% Default folders
pathRoot        = 'C:\OneDrive - Delft University of Technology\';
trdSemester     = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder    = '4. Semester - Thesis\OutputgprMax\Figures';
resultsPath     =  fullfile(pathRoot, trdSemester, 'Results');



%% Define output files to be loaded
% listing         = dir(resultsPath);
% listing         = struct2table( listing
% name = listing.name(listing.isdir == 0);


Syn = load("C:\OneDrive - Delft University of Technology\4. Semester - Thesis\SyntheticMexicanHat.mat");
syntheticMexicanHat = Syn.syntheticMexicanHat;



filenameArray = {'PlaceAntennas_Dist9.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist8.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist7.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist6.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist5.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist4.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist3.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist2.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist1.0m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'PlaceAntennas_Dist0.5m_tSim6.00e-08_eps1.00_iA1_iBH0.out',...
'Dist3.00m_tSim1.00e-07_iA1_iBH1-unsatGravel-waterBoreHole.out',...
'Dist3.00m_tSim1.00e-07_iA1_iBH1-satGravel-waterBoreHole.out',...
'Dist3.00m_tSim1.00e-07_iA1_iBH1-unsatGravel-airBoreHole.out',...
'Dist3.00m_tSim1.00e-07_iA1_iBH1-satGravel-airBoreHole.out',...
'Dist7.00m_tSim1.10e-07_iA1_iBH1-satGravel-waterBoreHole.out',...
'Dist7.00m_tSim1.10e-07_iA1_iBH1-satGravel-airBoreHole.out',...
'Dist7.00m_tSim1.10e-07_iA1_iBH1-unsatGravel-waterBoreHole.out',...
'Dist7.00m_tSim1.10e-07_iA1_iBH1-unsatGravel-airBoreHole.out',...
'Dist5.00m_tSim1.10e-07_iA1_iBH1-satGravel-airBoreHole.out',...
'Dist5.00m_tSim1.10e-07_iA1_iBH1-satGravel-waterBoreHole.out',...
'Dist5.00m_tSim1.10e-07_iA1_iBH1-unsatGravel-airBoreHole.out',...
'Dist5.00m_tSim1.10e-07_iA1_iBH1-unsatGravel-waterBoreHole.out'};

% filenameArray = {'PlaceAntennas_Dist1.0m_tSim5.10e-08_eps1.00_iA1_iBH0.out',...
%                  'PlaceAntennas_Dist2.0m_tSim5.10e-08_eps1.00_iA1_iBH0.out',...
%                  'PlaceAntennas_Dist3.0m_tSim5.10e-08_eps1.00_iA1_iBH0.out',...
%                  'PlaceAntennas_Dist5.0m_tSim5.10e-08_eps1.00_iA1_iBH0.out',...
%                  'PlaceAntennas_Dist7.0m_tSim5.10e-08_eps1.00_iA1_iBH0.out',...
%                  'Dist5.00m_tSim1e-07_iA1_iBH1-satGravel-airBoreHole.out',...
%                  'Dist5.00m_tSim1e-07_iA1_iBH1-unsatGravel-airBoreHole.out',...
%                  'Dist5.00m_tSim1e-07_iA1_iBH1-unsatGravel-waterBoreHole.out',...
%                  'Dist5.00m_tSim1e-07_iA1_iBH1-satGravel-waterBoreHole.out'};

name = filenameArray';

nFilesRaw = numel(name);
%% Analyse Parameter from data strings name

% isBorehole
isBoreHole  = zeros(nFilesRaw,1);
TF          = contains(name,"iBH" + digitsPattern);
match  = extract(name(TF), "iBH" + digitsPattern);
isBoreHole(TF)  = str2double(extract(match, digitsPattern));
isBoreHole(~TF) =  0;

% isAntenna
isRLFLA = zeros(nFilesRaw,1);
TF = contains(name,"iA" + digitsPattern);
match   = extract(name(TF), "iA" + digitsPattern);
isRLFLA(TF)   = str2double(extract(match, digitsPattern));
isRLFLA(~TF)  = 0;

% Distances
Distances   = extract(name, "Dist" + digitsPattern(1) + "." + digitsPattern(1,3) + "m" );
Distances   = str2double(extract(Distances, digitsPattern(1) + "." + digitsPattern(1,3)));

%eps
eps = NaN(nFilesRaw,1);
TF  = contains(name,  "eps" + digitsPattern(1,2) + "." + digitsPattern(1,2) );
match = extract(name(TF), "eps" + digitsPattern(1,2) + "." + digitsPattern(1,2) );
eps(TF) = str2double(extract(match, digitsPattern(1,2) + "." + digitsPattern(1,2)));

% MHz+ 
MHz = NaN(nFilesRaw,1);
TF  = contains(name,   digitsPattern(1,5) + "MHz");
match = extract(name(TF), digitsPattern(1,5) + "MHz" );
MHz(TF) = str2double(extract(match, digitsPattern));

% create table
Data = table(name,isBoreHole,isRLFLA,Distances,eps,MHz);

Data.eps(isBoreHole & contains(Data.name, "sat"))   = 12.5;
Data.eps(isBoreHole & contains(Data.name, "unsat")) = 5;

Data.epsBoreHole(isBoreHole & contains(Data.name, "water")) = 80;
Data.epsBoreHole(isBoreHole & (contains(Data.name, "air")) )   = 1;
Data.epsBoreHole(isBoreHole & (~contains(Data.name, "air")) & ~contains(Data.name, "water"))   = 80;
Data.epsBoreHole(~isBoreHole) = 1;

%discard files containing keywords
TF =  contains(name,  "res" |  "20eps" | "Ricker" | "satGravel20" | "Test" );
Data(TF,:) = [];

allData             = load_output([],Data.name, resultsPath);
fieldNames          = fieldnames(allData);


%% Load Data & First Breaks
for iField = 1:height(Data)
    fprintf('# %d', iField)
    tempData = allData.(fieldNames{iField}).Data.fields.(component);
    tempAxis  = allData.(fieldNames{iField}).Axis.time;
    FileName = allData.(fieldNames{iField}).FileName;
    fprintf('%s\n', FileName)

    [~,firstMinimum, maxAmplitude] = find1stBreak(tempData, tempAxis, thresholds(1));
    Data.maxAmplitude(iField) = maxAmplitude;
    Data.firstMinimum(iField) = firstMinimum;

    % First zero crossing
    idxFirstMin = find(tempAxis >= firstMinimum,1,'first');
    idxFirstZeroCross = find(tempData(idxFirstMin:end) >= 0,1, 'first');
    firstZeroCross  = tempAxis(idxFirstMin + idxFirstZeroCross);
    Data.FirstZeroCross(iField) = firstZeroCross;

    for iThresh = 1:numel(thresholds)
        name = ['firstBreake' num2str(threshExpo(iThresh)) ];
        firstBreak = find1stBreak(tempData, tempAxis, thresholds(iThresh));
        Data.(name)(iField) = firstBreak;
        Data.([name 'const1'])(iField) = firstMinimum - firstBreak;
        Data.([name 'const2'])(iField) = firstZeroCross - firstBreak;
%         Data.([name 'const3'])(iField) = maxAmplitude - firstBreak;
    end
end

%% Synthetic Wavelet
deltaTs = zeros(size(thresholds));
fprintf('Synthetic Wavelet\n')
for iDelta = 1:numel(deltaTs)
    [firstBreak,firstMinimumSynth,maxAmplitudeSynth] = find1stBreak(syntheticMexicanHat(:,2),...
                                                                    syntheticMexicanHat(:,1), ...
                                                                    thresholds(iDelta));
    deltaTs(iDelta) = firstBreak ;%  - firstBreak;

end

%% RLFLA Regression
regressionRows = find(Data.isBoreHole == false & Data.isRLFLA == true & Data.eps == 1);  
y = zeros(numel(regressionRows), numel(thresholds));

for iThresh = 1:numel(thresholds)
    name = ['firstBreake' num2str(threshExpo(iThresh))];
    y(:,iThresh) = Data.(name)(regressionRows);   
end

x = Data.Distances(regressionRows);
isFinite = isfinite(y);
y = y(all(isFinite,2),:);
x = x(all(isFinite,2));

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
set(gca,'FontSize',fs)
grid on
hold on


%% Plot regression
p = zeros(size(y,2),2);

colors = distinguishable_colors(numel(thresholds));
for iThresh = 1:numel(thresholds)
    p(iThresh,:) = polyfit(x,  y(:,iThresh), 1);
    r  = corrcoef(x*p(iThresh,1)+p(iThresh,2), y(:,iThresh));
    plot(x, x*p(iThresh,1)+p(iThresh,2), 'DisplayName',...
        sprintf('%.5e + x * %.5e \n r2 = %f', p(iThresh,2), p(iThresh,1), r(2,1)^2),...
        'Color', colors(iThresh,:))
    scatter(x,y(:,iThresh),ms,'filled','MarkerFaceColor', colors(iThresh,:),'DisplayName',...
    sprintf('Picked First Breaks e%f',threshExpo(iThresh)),'MarkerFaceAlpha', 0.5)
end

title('RLFLA - Linear Regression for t0 shift')
xlabel('TX - RX Separation [m]')
ylabel('Time [s]')
legend('Location','eastoutside')

%% travel time

isRLFLAisBorehole = Data.isBoreHole == true & Data.isRLFLA == true & Data.eps ~= 1;
isRLFLAisAir      = Data.isBoreHole == false & Data.eps == 1;
isWireAntena      = isRLFLAisBorehole & contains(Data.name, 'Wire');

%Caluclate Travel Time

% Borehole - RLFLA Cylinder 5cm borehole radius, 1cm air in antenna, 1cm
% insulator
Data.TrueTT  = ((sqrt(4)*2*0.01 + 2*0.01 + 2*0.03*sqrt(Data.epsBoreHole)+...
                   (Data.Distances-2*0.05).*sqrt(Data.eps))/cLight);

% Air
% Data.TrueTT =  Data.TrueTT + ((sqrt(4)*2*0.015 + 2*0.005 + (Data.Distances-2*0.02))./cLight) .* isRLFLAisAir;

% % Borehole - RLFLA Cylinder                  
% Data.TrueTT =  Data.TrueTT + ((sqrt(4)*2*0.02 + 2*0.03*sqrt(Data.epsBoreHole)+...
%                        (Data.Distances-2*0.05).*sqrt(Data.eps))/cLight) .* isWireAntena;

for iThresh = 1:numel(thresholds)
    name = ['firstBreake' num2str(threshExpo(iThresh))];
    approxTT = (Data.(name) - p(iThresh,2));
    Data.(['ApproxTTe' num2str(threshExpo(iThresh))])    = approxTT;
    Data.(['RelErrore' num2str(threshExpo(iThresh))])    = (approxTT - Data.TrueTT ) ./Data.TrueTT ;
end


%%  Determine TF table for boreholes and 

% Air Borehole - Unsaturated Gravel
isAirUnsat = isRLFLAisBorehole & Data.epsBoreHole == 1 & Data.eps  == 5;
% Air Borehole - Saturated Gravel
isAirSat = isRLFLAisBorehole & Data.epsBoreHole == 1 & Data.eps  == 12.5;
% Water Borehole - Unaturated Gravel
isWaterUnsat = isRLFLAisBorehole & Data.epsBoreHole == 80 & Data.eps  == 5;
% Water Borehole - Saturated Gravel
isWatSat = isRLFLAisBorehole & Data.epsBoreHole == 80 & Data.eps == 12.5;

boreTFTable = table((~isBoreHole),isAirUnsat, isAirSat,isWaterUnsat,isWatSat, 'VariableNames',...
    {'homogeneous air','Air Borehole - unsaturated Gravel','Air Borehole - saturated Gravel', 'Water Borehole - unsaturated Gravel','Water Borehole - saturated Gravel'});

%% Plot regression error
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
hold on

colors = distinguishable_colors(size(boreTFTable,2));
for iBorehole = 1:size(boreTFTable,2)
    for iThresh = 1:numel(thresholds)
        name = (['RelErrore' num2str(threshExpo(iThresh))]);
        scatter(Data.Distances( boreTFTable{:,iBorehole} ),...
            100* Data.(name)(  boreTFTable{:,iBorehole}), ms, ...
                 colors(iBorehole,:),'filled',mkrs{iThresh} ,...
                 'DisplayName',sprintf('%s with %.1e',...
                 boreTFTable.Properties.VariableNames{iBorehole}, thresholds(iThresh)),...
                 'MarkerFaceAlpha',alpha)
    end
end
yline(0,'--','HandleVisibility','off')

title(sprintf('RLFLA - interpolated time shift'))
ylabel('relative error [%]')
xlabel('TX-RX distance [m]')
legend('Location','eastoutside')

%% Travel Time Error delta-t synthetic and picked
for iThresh = 1:numel(thresholds)
    name = ['firstBreake' num2str(threshExpo(iThresh))];
    Data.(['DeltaFirstBreakErrore' num2str(threshExpo(iThresh))]) = (Data.(name) - deltaTs(iThresh) - Data.TrueTT) ./ Data.TrueTT ;
end

Data.DeltaMaxError = (Data.maxAmplitude - maxAmplitudeSynth -  Data.TrueTT) ./ Data.TrueTT ;
Data.DeltaMinError = (Data.firstMinimum - firstMinimumSynth -  Data.TrueTT) ./ Data.TrueTT ;
%% Homogeneous Air vs distance deltat


figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
hold on

names = cell(numel(thresholds),1);
for iName = 1:numel(thresholds)
    names{iName} = (['DeltaFirstBreakErrore'  num2str(threshExpo(iName))]);
end

names = ['DeltaMaxError';'DeltaMinError';names];

colors = distinguishable_colors(numel(names));
for iDelta = 1:numel(names)
    name = names{iDelta};
    scatter(Data.Distances( ~isBoreHole   ), 100*Data.(name)( ~isBoreHole    ), ms,...
        colors(iDelta,:),'filled' ,mkrs{iDelta},'MarkerFaceAlpha',alpha, ...
        'DisplayName', sprintf('%s',name))
end
yline(0,'--','HandleVisibility','off')

title(sprintf('Substraction of synthetic reference points to measured wavelet'))
if numel(thresholds) == 1
    subtitle(sprintf('Relative Threshold: %% %.1f of first minimum', 100*thresholds))    
end
ylabel('relative error [%]')
xlabel('TX-RX distance [m]')
legend('Location','eastoutside')

%% Boreholes vs delta t 
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
set(gca(),'xscale','log')
hold on

colors =  distinguishable_colors(size(boreTFTable,2));

for iBorehole = 2:size(boreTFTable,2)
    for iThresh = 1:numel(thresholds)
        currentThresh = thresholds(iThresh);
        name1 = 'DeltaMaxError';
        name2 = 'DeltaMinError';
    
        currentLine1 = scatter(repmat(currentThresh,[sum( boreTFTable{:,iBorehole}  & Data.Distances == distance2plot),1] ),...
                100* Data.(name1)(  boreTFTable{:,iBorehole} & Data.Distances == distance2plot ), ms, ...
            	colors(iBorehole,:),mkrs{iBorehole} ,...
            	'MarkerFaceAlpha',alpha,'HandleVisibility','Off'); %-iThresh/numel(thresholds))
        currentLine2 = scatter(repmat(currentThresh,[sum( boreTFTable{:,iBorehole}  & Data.Distances == distance2plot),1] ),...
                100* Data.(name2)(  boreTFTable{:,iBorehole} & Data.Distances == distance2plot), ms, ...
            	colors(iBorehole,:),'filled',mkrs{iBorehole} ,...
            	...
            	'MarkerFaceAlpha',alpha,'HandleVisibility','Off'); %-iThresh/numel(thresholds))

    end

   currentLine1.HandleVisibility = 'on';
   currentLine1.DisplayName = sprintf('%s %s',boreTFTable.Properties.VariableNames{iBorehole}, name1);
   currentLine2.HandleVisibility = 'on';
   currentLine2.DisplayName = sprintf('%s %s',boreTFTable.Properties.VariableNames{iBorehole}, name2);
       

end

yline(0,'--','HandleVisibility','off')

title(sprintf('Travel Time Error for a %.1f m distance ', distance2plot))
xlabel('Threshold first pick above first minimum')
ylabel('Relativer Error [%]')

ylim([-max(abs(ylim)) max(abs(ylim)) ])
legend('Location','eastoutside','FontSize',fs)


%% Plot Constants vs thresholds
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
set(gca(),'xscale','log')
hold on

iterCounter = 0;
for iConst = 1:2
    for iBorehole = 1:size(boreTFTable,2)
        for iThresh = 1:numel(thresholds)

        iterCounter = iterCounter + 1;
        currentThresh = thresholds(iThresh);
        name = ['firstBreake' num2str(threshExpo(iThresh)) 'const' num2str(iConst)];
    
        currentLine = scatter(repmat(currentThresh,[sum( boreTFTable{:,iBorehole} & Data.Distances == distance2plot),1] ),...
                Data.(name)(  boreTFTable{:,iBorehole} & Data.Distances == distance2plot), ms, ...
            	colors(iBorehole,:),'filled',mkrs{iConst} ,...
            	'MarkerFaceAlpha',alpha, 'Handlevisibility','Off','DisplayName',sprintf('%s constant %d',...
            	boreTFTable.Properties.VariableNames{iBorehole},iConst)); %-iThresh/numel(thresholds))

        %         scatter(repmat(currentThresh,[sum( boreTFTable{:,iBorehole},1)] ),...
%                 100* Data.(name2)(  boreTFTable{:,iBorehole}), ms, ...
%             	colors(iBorehole,:),'filled',mkrs{iThresh} ,...
%             	'DisplayName',sprintf('%s with synthetic %.2e',...
%             	boreTFTable.Properties.VariableNames{iBorehole}, thresholds(iThresh)),...
%             	'MarkerFaceAlpha',alpha) %-iThresh/numel(thresholds))

        end
        currentLine.HandleVisibility = 'On';
    end
    currentLine.HandleVisibility = 'On';
end

legend('Location','eastoutside')
title('Constans #1 #2 #3 vs thresholds for first break pick for a %.1f m distance',distance2plot)



%% Plot Ratio vs thresholds
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
set(gca(),'xscale','log')
hold on


tfAir =  boreTFTable{:,1} & Data.Distances == distance2plot;

colors = distinguishable_colors(3*size(boreTFTable,2));

iterCounter = 0;

    for iBorehole = 1:size(boreTFTable,2)
        for iThresh = 1:numel(thresholds)

        iterCounter = iterCounter + 1;
        currentThresh = thresholds(iThresh);
        tf = boreTFTable{:,iBorehole} & Data.Distances == distance2plot;
        nameFirstBreak = ['firstBreake' num2str(threshExpo(iThresh))];
        
        ratio = (Data.maxAmplitude(tf) - Data.firstMinimum(tf)) ./ ...
                (Data.maxAmplitude(tfAir) - Data.firstMinimum(tfAir)); %.*...
                %(Data.firstMinimum(tfAir) - Data.(nameFirstBreak)(tfAir));

        currentLine = scatter(repmat(currentThresh,[sum( tf),1] ),...
                ratio, ms, ...
            	colors(iBorehole,:),'filled',mkrs{iThresh} ,...
            	'MarkerFaceAlpha',alpha, 'Handlevisibility','On','DisplayName',sprintf('ratio for %s with %e threshold',...
            	boreTFTable.Properties.VariableNames{iBorehole},currentThresh)); %-iThresh/numel(thresholds))

        end
    end

legend('Location','eastoutside')
title('Ratio for different thresholds')


%% Plot Constants vs Distance in air
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
hold on

colors = distinguishable_colors(numel(thresholds));
for iConst = 1:2
    for iThresh = 1:numel(thresholds)
        currentThresh = thresholds(iThresh);
        name = ['firstBreake' num2str(threshExpo(iThresh)) 'const' num2str(iConst)];
    
        currentLine = scatter(Data.Distances(boreTFTable{:,1}),...
                Data.(name)(  boreTFTable{:,1}), ms, ...
        	    colors(iConst,:),'filled',mkrs{iThresh} ,...
        	    'MarkerFaceAlpha',alpha, 'Handlevisibility','On','DisplayName',sprintf('%s constant %d - %.2e',...
        	    boreTFTable.Properties.VariableNames{iBorehole}, iConst, currentThresh)); %-iThresh/numel(thresholds))

    end
end

 title('Constants #1 #2 vs distance')
legend('Location','eastoutside')
xlabel('Distance [m]')

%% Plot Ratio vs distances
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
set(gca(),'xscale','log')
hold on


colors = distinguishable_colors(3*size(boreTFTable,2));

distances = Data.Distances(~~isBoreHole);

for iBorehole = 1:size(boreTFTable,2)
    for iDistance = distances'
    currentThresh = thresholds(iThresh);
    tfAir = boreTFTable{:,1} & Data.Distances == iDistance;
    tf    = boreTFTable{:,iBorehole} & Data.Distances == iDistance;
    nameFirstBreak = ['firstBreake' num2str(threshExpo(iThresh))];
    
    ratio = (Data.maxAmplitude(tf) - Data.firstMinimum(tf)) ./ ...
            (Data.maxAmplitude(tfAir) - Data.firstMinimum(tfAir)); %.*...
            %(Data.firstMinimum(tfAir) - Data.(nameFirstBreak)(tfAir));

    currentLine = scatter(iDistance,...
            ratio, ms, ...
        	colors(iBorehole,:),'filled',mkrs{iThresh} ,...
        	'MarkerFaceAlpha',alpha, 'Handlevisibility','Off','DisplayName',sprintf('ratio for %s',...
        	boreTFTable.Properties.VariableNames{iBorehole})); %-iThresh/numel(thresholds))
    end
    currentLine.HandleVisibility = 'on';
end


legend('Location','eastoutside')
title('Ratio for different thresholds vs distance')

%% Plot  error
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
hold on

colors = distinguishable_colors(size(boreTFTable,2));
name = 'DeltaFirstBreakErrore-3';
for iBorehole = 1:size(boreTFTable,2)
        
        scatter(Data.Distances( boreTFTable{:,iBorehole} ),...
            100* Data.(name)(  boreTFTable{:,iBorehole}), ms, ...
                 colors(iBorehole,:),'filled',mkrs{iThresh} ,...
                 'DisplayName',sprintf('%s',...
                 boreTFTable.Properties.VariableNames{iBorehole}),...
                 'MarkerFaceAlpha',alpha)
end

yline(0,'--','HandleVisibility','off')

title(sprintf('RLFLA - travel time with synthetic wavelet for %s', name))
ylabel('relative error [%]')
xlabel('TX-RX distance [m]')
legend('Location','eastoutside')

%% Plot Constants vs Distance
figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn',{@SaveFigure,fullfile(pathRoot, figureFolder)});
grid on
set(gca,'FontSize',fs)
hold on

distances = Data.Distances(~~isBoreHole);
distancesTF = ismember(Data.Distances, distances); 

colors = distinguishable_colors(numel(thresholds)*2*size(boreTFTable,2));
for iBorehole = 1:size(boreTFTable,2)
    for iConst = 1:2
        for iThresh = 1
            currentThresh = thresholds(iThresh);
            name = ['firstBreake' num2str(threshExpo(iThresh)) 'const' num2str(iConst)];
        
            currentLine = scatter(Data.Distances(boreTFTable{:,iBorehole} & distancesTF),...
                    Data.(name)(  boreTFTable{:,iBorehole} & distancesTF), ms, ...
            	    colors(iBorehole,:),'filled',mkrs{iConst} ,...
            	    'MarkerFaceAlpha',alpha, 'Handlevisibility','On','DisplayName',sprintf('%s constant %d - %.2e',...
            	    boreTFTable.Properties.VariableNames{iBorehole}, iConst, currentThresh)); %-iThresh/numel(thresholds))
    
        end
    end
end
 title('Constants #1 #2 vs distance')
legend('Location','eastoutside')
xlabel('Distance [m]')
