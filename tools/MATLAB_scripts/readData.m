clear , close all
fullPath = 'C:\OneDrive - Delft University of Technology\4. Semester - Thesis\ObservationsGradient.xlsx';
data     = readtable(fullPath, 'Sheet','Gradient');

%filter options
contrast1 = '5-6';
contrast2 = '6-5';
thicknes  = [10,25,50];

dataFiltered = data( ((strcmp(data.contrast,contrast1) | strcmp(data.contrast,contrast2)) & ismember(data.thickness,thicknes) ),:);

uniqueGradient = unique(dataFiltered.Gradient);
uniqueContrast = unique(dataFiltered.contrast);

figure
set(gcf,'Color','white')
t = tiledlayout(2,2);


effTileAir = nexttile;
title('Effective Frequency Air')
ylabel('Frequency (MHz)')
grid on
hold on
lg = legend('Interpreter','none', 'Orientation','Vertical','NumColumns',2);
lg.Layout.Tile = 'south';

fftTileAir = nexttile;
title('FFT Frequency Air')
hold on
grid on

effTileGround = nexttile;
title('Effective Frequency Ground')
xlabel('Offset (m)')
ylabel('Frequency (MHz)')
hold on
grid on

fftTileGround = nexttile;
title('FFT Frequency Ground')
xlabel('Offset (m)')
hold on
grid on


offest = [3.1,4.1,6.1];

fieldsEff = {
'effFreqAir3_1m';
'effFreqAir4_1m';	
'effFreqAir6_1m';	
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

colors = distinguishable_colors(numel(uniqueGradient)*numel(uniqueContrast)*3);
counter = 0;

for iGradient = 1:numel(uniqueGradient)
    for iContrast = 1:numel(uniqueContrast)
        tfData = strcmp(dataFiltered.Gradient,uniqueGradient(iGradient)) & strcmp(dataFiltered.contrast,uniqueContrast(iContrast))  ;
        if any(tfData)
            dataSelAll = dataFiltered(tfData,:);
            for iThickness = 1:height(dataSelAll)
                counter = counter + 1;
                color   = colors(counter,:);


                dataSel = dataSelAll(iThickness,:);
                plot(offest,dataSel{:,fieldsEff(1:3)}./1e6*0.5,'-o','DisplayName',sprintf('%s (%s) - %dcm',...
                    dataSel.Gradient{:},dataSel.contrast{:} ,dataSel.thickness),'Parent',effTileAir,'Color',color)
                plot(offest,dataSel{:,fieldsEff(4:6)}./1e6*0.5,'-o','Parent',effTileGround,'Color',color)
                plot(offest,dataSel{:,fieldsFFT(1:3)},'-o','Parent',fftTileAir,'Color',color)
                plot(offest,dataSel{:,fieldsFFT(4:6)},'-o','Parent',fftTileGround,'Color',color)

%                 text(pi,0,'\leftarrow sin(\pi)')


            end
        end
    end
end

