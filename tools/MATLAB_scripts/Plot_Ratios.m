clear,close all
%% Parameter
fs = 30;
lw = 2;
ylimit = 6;
%% Lossless 200MHz Dipole

%
eps = [
5
6
10
15
20
25
30
40
50
60
80
];

ag_maxmax = [
0.740442
0.758835
0.836658
0.939253
1.045502
1.155131
1.268369
1.506525
1.761261
2.032971
2.783382
];

ag_negmax = [
1.157413
1.191878
1.343944
1.554479
1.781419
2.023014
2.278934
2.833812
3.446767
4.118293
5.636872
];

figure
set(gca,'FontSize',fs)
grid on
hold on
% plot(eps,ag_maxmax,'-o','LineWidth',lw,'DisplayName','DGA/DGW (max positive/max positive)')
plot(eps,ag_negmax,'-o','LineWidth',lw,'DisplayName','DGA/DGW (max negative/max positive)')
legend
xlabel('Relative Permittivity [-]')
title('Ratio Airwave-Groundwave - 2D')
subtitle('200MHz Hertzian Dipole')
ylim([0 ylimit])
lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical',...
    'Location','northwest');


m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
     'MenuSelectedFcn',@SaveFigure);

%% RLFLA Lossless 
eps = [
5
6
8
10
15
25
30
40
50
60
80 
];

ag_maxmax = [
0.781555
0.779068
0.784711
0.798629
0.850849
0.992381
1.075514
1.278474
1.491498
1.731636
2.289433    
];

ag_negmax =[
0.97848
0.975148
0.983382
0.999653
1.056154
1.200457
1.282007
1.459682
1.654812
1.866722
2.358269    
];

figure
set(gca,'FontSize',fs)
grid on
hold on
ylim([0 ylimit])
plot(eps,ag_maxmax,'-o','LineWidth',lw,'DisplayName','DGA/DGW (max positive/max positive)')
plot(eps,ag_negmax,'-o','LineWidth',lw,'DisplayName','DGA/DGW (max negative/max positive)')
legend
xlabel('Relative Permittivity [-]')
title('Ratio Airwave-Groundwave - 3D')
subtitle('RLFLA')

lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical',...
    'Location','northwest');


m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
     'MenuSelectedFcn',@SaveFigure);


