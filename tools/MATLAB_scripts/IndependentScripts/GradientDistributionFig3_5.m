clc, clear ,close all

% Plot the gradient distributions (Fig. 3.5). 
% Define start permittivity eps 0
% Define end permittivity epsEnd
% Define amount of gradient layer (default is 1000).

%% MAIN
p          = mfilename('fullpath');
script_dir = fileparts(p);
addpath(genpath(script_dir));
%%

epsA     = 1;
eps0     = 5;
epsEnd   = 5;
n        = 1000;
c0       = 3e8/1e9;

color = 'b';

hAir        = 0.2;
hGradient   = 0.3;
hHomo       = 0.5;

nGradientLayers = n;

hString = []; % Fill in number to display gradient thickness

lw = 3.5;
fs = 20;
fsLine = 0.8*fs;

epsVectorSoil = linspace(eps0,eps0,nGradientLayers+1);
hVectorSoil   = linspace(hAir,hAir+hGradient,nGradientLayers+1);
epsVectorSoil = [eps0 ,epsVectorSoil(1:end-1)];
[epsVectorSoil,hVectorSoil] = stairs(epsVectorSoil,hVectorSoil);
    

velocVectorSoil = c0./sqrt(epsVectorSoil);
velocHomo       = c0/sqrt(epsEnd);
xlimEnd         = 14;


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
xlim([0 xlimEnd])

plot([epsA,epsA],[0,hAir],'Color',color,'LineWidth',lw)
plot([epsA,eps0],[hAir, hAir],'Color',color,'LineWidth',lw)
plot(epsVectorSoil,hVectorSoil,'Color',color,'LineWidth',lw)
plot([epsVectorSoil(end),epsEnd],[hVectorSoil(end) hVectorSoil(end)],'Color',color,'LineWidth',lw)
plot([epsEnd,epsEnd],[hAir+hGradient,hAir+hGradient+hHomo],'Color',color,'LineWidth',lw)

yline(hAir,'--','','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient,'--','','FontSize',fsLine,'LineWidth',0.5*lw);
yline(hAir+hGradient+hHomo,'--','','FontSize',fsLine,'LineWidth',0.5*lw);

if ~isempty(hString)
    p1 = [2 hAir];                         % First Point
    p2 = [2, hAir+hGradient];                         % Second Point
    dp = p2-p1;                         % Difference
    quiver(p1(1),p1(2),dp(1),dp(2),0,'LineWidth',lw,'Color','red','ShowArrowHead','on')
    text(p1(1)*1.1,0.5*(p1(2)+p2(2)), sprintf('h = %dcm',hString),'FontSize',0.8*fs,...
        'FontWeight','bold','Color','red')
%     a = annotation('doublearrow',x,y);
else
   p1 = [2 hAir];                         % First Point
    p2 = [2, hAir+hGradient];                         % Second Point
    dp = p2-p1;                         % Difference
    quiver(p1(1),p1(2),dp(1),dp(2),0,'LineWidth',lw,'Color','red','ShowArrowHead','on')
    text(p1(1)*1.1,0.5*(p1(2)+p2(2)), sprintf('h'),'FontSize',0.8*fs,...
        'FontWeight','bold','Color','red') 
end
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


