function[err]=procconstraint_sigma1_estimation(x,ampexp,max_fsyn,offset,mu0,eps, axis)
% adapted from @Anja Klotzsche
% Estimate conductivity from ground wave based on exponential expression in Eq. 2.19.
% INPUT:
% x         : double [2x1] containing parameters to be optimized (conductivity and Initial amplitude)
% ampexp    : double [nx1] - measured/picked amplitudes 
% max_fsyn  : double - max(ampexp)
% offset    : double [nx1] - offset of amplitudes
% mu0       : double - magnetic permeability in free space
% eps       : double - permittivity
% axis      : axis object to display estimation vs measured
%
% OUTPUT:
% err               : error information


sigma = x(1);
A0    = x(2);

ampsyn=(A0.*exp(-sigma.*offset.*0.5.*sqrt(mu0/eps)))./(offset.^2);

plot(offset,ampexp,'-bo','DisplayName','Measured Value','Parent',axis)
hold on
grid on
plot(offset,ampsyn,'--ro','DisplayName','Estimated Value','Parent',axis)
hold off

err=sum(abs(ampsyn-ampexp).^2)/numel(offset);
cor_factor=ampexp(1)/max_fsyn(1);
%disp([err]);
%save('cor_factor','cor_factor','ampexp','ampsyn');
