clear, close all


% Default folders

trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';

pathRoot = 'C:\OneDrive - Delft University of Technology\';
name     = 'TimeZeroData.mat';
fileName = fullfile(pathRoot,'4. Semester - Thesis',  name);

load(fileName);
data = T0Data.data;


cLight = 299792458; %[m/S];
fs = 16;
ms = 60;
%% RLFLA Regression

regressionRows = find(data.isBoreHole == false & data.isRLFLA == true);  

x = data.Separation(regressionRows);
y = data.("FBnonZeroThresh1e-7")(regressionRows);   

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');
set(gca,'FontSize',fs)
grid on
hold on

p = polyfit(x,  y, 1);

r = corrcoef(x*p(1)+p(2), y);

plot(x, x*p(1)+p(2), 'DisplayName',sprintf('%.5e + x * %.5e \n r2 = %f', p(2), p(1), r(2,1)^2))
scatter(x,y,ms,'filled','Color', 'red','DisplayName','Picked First Breaks (1e-7)','MarkerFaceAlpha', 0.5)
title('RLFLA - Linear Regression for t0 shift')
xlabel('TX - RX Separation [m]')
ylabel('Time [s]')
legend

t0ShiftRLFLA = p(2);
%% Point Dipole Regression
regressionRows = find(data.isBoreHole == false & data.isRLFLA == false & isfinite(data.("FBnonZeroThresh1e-7")));
x = data.Separation(regressionRows);
y = data.("FBnonZeroThresh1e-7")(regressionRows);   

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');
grid on
set(gca,'FontSize',fs)
hold on


p = polyfit(x,  y, 1);

r = corrcoef(x*p(1)+p(2), y);

plot(x, x*p(1)+p(2), 'DisplayName',sprintf('%.5e + x * %.5e \n r2 = %f', p(2), p(1), r(2,1)^2))
scatter(x,y,ms,'filled','Color', 'red','DisplayName','Picked First Breaks (1e-7)')
title('Point Dipole 125MHz Linear Regression for t0 shift')
xlabel('Separation')
ylabel('Time [s]')
legend

t0ShiftPoint = p(2);


travelTimeIsRLFLAisBorehole = data.isBoreHole == true & data.isRLFLA == true;
travelTimeIsRLFLAisAir      = data.isBoreHole == false;
data.TrueTT  = ((sqrt(4)*2*0.01 + 2*0.01 + 2*0.03*sqrt(data.e_rBorehole)+...
                   (data.Separation-2*0.05).*sqrt(data.er))/cLight).*travelTimeIsRLFLAisBorehole + ...
                   ((sqrt(4)*2*0.01 + 2*0.01* + (data.Separation-2*0.02))/cLight) .* travelTimeIsRLFLAisAir;

data.ApproxTT = (data.("FBnonZeroThresh1e-7") - t0ShiftRLFLA).*travelTimeIsRLFLAisBorehole;
data.RelError    = ((data.ApproxTT - data.TrueTT ) ./data.TrueTT ).*travelTimeIsRLFLAisBorehole;



% Water Borehole - Saturated Gravel
isWatSat = travelTimeIsRLFLAisBorehole & data.e_rBorehole == 80 & data.er == 12.5;
% Air Borehole - Saturated Gravel
isAirSat = travelTimeIsRLFLAisBorehole & data.e_rBorehole == 1 & data.er == 12.5;
% Air Borehole - Unsaturated Gravel
isAirUnsat = travelTimeIsRLFLAisBorehole & data.e_rBorehole == 1 & data.er == 5;
% Water Borehole - Unaturated Gravel
isWaterUnsat = travelTimeIsRLFLAisBorehole & data.e_rBorehole == 80 & data.er == 5;

figure
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
         'MenuSelectedFcn','SaveFigure(fullfile(pathRoot, figureFolder))');
grid on
set(gca,'FontSize',fs)
hold on

scatter(data.Separation( isAirUnsat   ), 100* data.RelError( isAirUnsat    ), ms, ...
         'filled' , 'DisplayName','Air Borehole - unsaturated Gravel')
scatter(data.Separation( isAirSat   ), 100*data.RelError( isAirSat    ), ms, ...
        'filled' ,'DisplayName','Air Borehole - saturated Gravel')   
scatter(data.Separation( isWaterUnsat   ), 100*data.RelError( isWaterUnsat    ), ms,...
        'filled'  , 'DisplayName','Water Borehole - unsaturated Gravel') 
scatter(data.Separation( isWatSat   ), 100*data.RelError( isWatSat    ), ms,...
        'filled' ,'DisplayName','Water Borehole - saturated Gravel') 

yline(0,'--','HandleVisibility','off')

title(sprintf('RLFLA - interpolated time shift %e', t0ShiftRLFLA))
ylabel('relative error [%]')
xlabel('TX-RX distance [m]')
legend

