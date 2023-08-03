clear %, close all

% Plot center frequency distribution along depth that has been saved in
% ObservationsGradient.xlsx. (Fig. 5.16 in Thesis).

fullPath = 'Excel-Files/ObservationsGradient.xlsx';
data     = readtable(fullPath, 'Sheet','Gradient');

fs = 25;  % Font Size

%filter options
contrast1 = '5-6'; % or '5-12.5';  
contrast2 = '6-5'; % or '12.5-5';  


%% Load and plot data
thicknes  = [10,25,50];
source = '200 MHz Infinite Dipole';

dataFiltered = data( ((strcmp(data.contrast,contrast1) | strcmp(data.contrast,contrast2)) & ismember(data.thickness,thicknes) & ismember(data.Source,source) ),:);

uniqueGradient = unique(dataFiltered.Gradient);
uniqueContrast = unique(dataFiltered.contrast);
uniqueContrast = flip(uniqueContrast);

figure
set(gcf,'Color','white')

% set(gca,'XTick',1:1:offset(end));


t = tiledlayout(1,2);


fftTileAir = nexttile;
title('FFT Frequency Air')
hold on
grid on
lg = legend('Interpreter','none', 'Orientation','Vertical','NumColumns',2,'FontSize',0.75*fs);
lg.Layout.Tile = 'south';
 set(gca,'FontSize',fs)
 xlabel('Offset (m)')
 ylabel('Frequency (MHz)')
set(gca,'TickDir','out');


fftTileGround = nexttile;
title('FFT Frequency Ground')
xlabel('Offset (m)')

hold on
grid on
 set(gca,'FontSize',fs)
set(gca,'TickDir','out');



offestEff = [1.1,3.1,4.1,6.1];
offest= [3.1,4.1,6.1];

fieldsEff = {
'effFreqAir1_1m';
'effFreqAir3_1m';
'effFreqAir4_1m';	
'effFreqAir6_1m';
'effFreqGround1_1m';
'effFreqGround3_1m';	
'effFreqGround4_1m';
'effFreqGround6_1m'};

fieldsFFT = {
'fftAir3_1m'; 
'fftAir4_1m';	
'fftAir6_1m';	
'fftGround3_1m'	;
'fftGround4_1m'	;
'fftGround6_1m'};

colors = distinguishable_colors(4);
counter = 0;
lineStyles = {'--o',':+','-.*'};
lw =1.5;

for iGradient = 1:numel(uniqueGradient)
    for iContrast = 1:numel(uniqueContrast)
        tfData = strcmp(dataFiltered.Gradient,uniqueGradient(iGradient)) & strcmp(dataFiltered.contrast,uniqueContrast(iContrast))  ;
        if any(tfData)
            dataSelAll = dataFiltered(tfData,:);
            counter = counter + 1;
            color   = colors(counter,:);
            for iThickness = 1:height(dataSelAll)
                
    
                dataSel = dataSelAll(iThickness,:);
%                 plot(offestEff,dataSel{:,fieldsEff(1:4)}./1e6*0.5,lineStyles{iThickness},'Parent',effTileAir,'Color',color,'LineWidth',lw)
%                 plot(offestEff,dataSel{:,fieldsEff(5:end)}./1e6*0.5,lineStyles{iThickness},'Parent',effTileGround,'Color',color,...
%                     'DisplayName',sprintf('%s (%s) - %dcm',dataSel.Gradient{:},dataSel.contrast{:} ,dataSel.thickness),...
%                     'LineWidth',lw)
                plot(offest,dataSel{:,fieldsFFT(1:3)},lineStyles{iThickness},'Parent',fftTileAir,'Color',color,'LineWidth',lw, ...
                    'DisplayName',sprintf('%s (%s) - %dcm',dataSel.Gradient{:},dataSel.contrast{:} ,dataSel.thickness))
                plot(offest,dataSel{:,fieldsFFT(4:6)},lineStyles{iThickness},'Parent',fftTileGround,'Color',color,'LineWidth',lw)

%                 text(pi,0,'\leftarrow sin(\pi)')


            end
        end
    end
end

m = uimenu('Text','USER-Options');
uimenu(m, 'Text', 'Save', 'MenuSelectedFcn', @SaveFigure)

limits = get(gca,'YLim');


linkaxes([fftTileAir,fftTileGround],'xy')

