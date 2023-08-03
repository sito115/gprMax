clear,close all
%% Parameter
% Plot center frequencies for a homogeneous halfspace of increasing
% permittivites (Fig.5.4) for a 130MHz and 200MHz Hertzian Dipole.

%% Parameter

fs = 30; % font size
lw = 2;  % line width
ylimitlow = 50;  % lower limit of yaxis
ylimit = 230;    % upper limit fo yaxis
%% Lossless 200MHz Dipole

%
eps200 = [
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

freq_air = [
161.893666
161.448903
168.72684
175.802612
179.643745
185.66826
188.822032
198.525948
188.943331
205.491974
210.27173
];

freq_ground = [
136.871425
147.591942
133.544368
140.475737
121.714832
116.816665
121.807251
105.726475
105.726475
100.920727
95.190795
];

eps130 = [
5
6
10
15
20
30
40
50
60
80
];

freq_air130 = [
105.449221
106.096148
109.54643
113.859281
118.279954
124.425768
129.493368
132.943649
135.747003
139.628569
];


freq_ground130 = [
89.276027
92.295023
86.472674
86.041389
76.9844
72.455906
67.280484
65.986629
62.75199
56.713998
    ];



figure
set(gca,'FontSize',fs)
grid on
hold on
plot(eps130,freq_air130,'--o','LineWidth',lw,'DisplayName','DAW (130 MHz)','Color','red')
plot(eps130,freq_ground130,'-o','LineWidth',lw,'DisplayName','DGW (130 MHz)','Color','red')
plot(eps200,freq_air,'--o','LineWidth',lw,'DisplayName','DAW (200 MHz)','Color','blue')
plot(eps200,freq_ground,'-o','LineWidth',lw,'DisplayName','DGW (200 MHz)','Color','blue')
legend
xlabel('Relative Permittivity [-]')
ylabel('Frequency [MHz]')
title('Ratio Center Frequencies - 2D')
subtitle('200MHz Hertzian Dipole')
ylim([ylimitlow ylimit])
lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical',...
    'Location','north','NumColumns',4);


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

freq_air = [
99.8325
99.8325
101.417142
101.417142
101.417142
103.001785
104.586428
106.171071
109.340357
113.143499
115.045071  
];

freq_ground =[
102.473571
99.568392
98.247857
96.663214
95.078571
89.532321
89.268214
83.986071
83.986071
80.816785
77.6475   
];

figure
set(gca,'FontSize',fs)
grid on
hold on
ylim([ylimitlow ylimit])
plot(eps,freq_air,'-o','LineWidth',lw,'DisplayName','DAW')
plot(eps,freq_ground,'-o','LineWidth',lw,'DisplayName','DGW')
legend
xlabel('Relative Permittivity [-]')
title('Ratio Center Frequencies - 3D')
subtitle('RLFLA')

lg = legend('Interpreter','none', 'FontSize', 0.75*fs, 'Orientation','Vertical',...
    'Location','northwest');


m = uimenu('Text','USER-Options');
uimenu(m,'Text','Save Figure',...
     'MenuSelectedFcn',@SaveFigure);


