% plot_Bscan.m
clc, clear ,close all
%% MAIN
p          = mfilename('fullpath');
script_dir = fileparts(p);
addpath(genpath(script_dir));
%%

epsA     = 1;
eps0     = 6;
epsEnd   = 5;
n        = 1000;
c0       = 3e8/1e9;

color = 'b';

hAir        = 0.2;
hGradient   = 0.3;
hHomo       = 0.5;

lw = 3.5;
fs = 25;
fsLine = fs;

epsVectorSoil = linspace(eps0, eps0, n);
hVectorSoil   = linspace(hAir, hAir+hGradient, n);
velocVectorSoil = c0./sqrt(epsVectorSoil);
velocHomo     = c0/sqrt(epsEnd);


f = figure;
t = tiledlayout(1,2);

%%
nexttile
set(gca, 'YDir', 'reverse')
ax = gca;
ax.FontSize = fs;
hold on
grid on
xlabel('Relative Permittivity [-]','FontSize',fs)
ylabel('Dimensionless depth [-]','FontSize',fs)
ylim([0, hAir+hGradient+hHomo])
xlim([0 14])
plot([epsA,epsA],[0,hAir],'Color',color,'LineWidth',lw)
plot([epsA,eps0],[hAir, hAir],'Color',color,'LineWidth',lw)
plot(epsVectorSoil,hVectorSoil,'Color',color,'LineWidth',lw)
plot([epsVectorSoil(end),epsEnd],[hVectorSoil(end) hVectorSoil(end)],'Color',color,'LineWidth',lw)
plot([epsEnd,epsEnd],[hAir+hGradient,hAir+hGradient+hHomo],'Color',color,'LineWidth',lw)

yline(hAir,'--','','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient,'--','','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient+hHomo,'--','','FontSize',fsLine,'LineWidth',0.5*lw);

%%
nexttile
set(gca, 'YDir', 'reverse')
ax = gca;
ax.FontSize = fs;
hold on
grid on
xlabel('Velocity [m/ns]','FontSize',fs)
ylim([0, hAir+hGradient+hHomo])
xlim([0.05 0.35])
plot([c0,c0],[0,hAir],'Color',color,'LineWidth',lw)
plot([c0,velocVectorSoil(1)],[hAir, hAir],'Color',color,'LineWidth',lw)
plot(velocVectorSoil,hVectorSoil,'Color',color,'LineWidth',lw)
plot([velocVectorSoil(end),velocHomo],[hVectorSoil(end) hVectorSoil(end)],'Color',color,'LineWidth',lw)
plot([velocHomo,velocHomo],[hAir+hGradient,hAir+hGradient+hHomo],'Color',color,'LineWidth',lw)

yline(hAir,'--','Air','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient,'--','Gradient Layer','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient+hHomo,'--','Homogeneous Layer','FontSize',fsLine,'LineWidth',0.5*lw);
%%
m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
     'MenuSelectedFcn',@SaveFigure);
