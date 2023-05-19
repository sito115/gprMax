function[err]=procconstraint_sigma1_estimation(x,ampexp,max_fsyn,offset,mu0,eps, axis)

sigma = x(1);
A0    = x(2);

% ampsyn=(max_fsyn.*(ampexp(1)/max_fsyn(1)).*exp(x.*offset(1).*0.5.*sqrt(mu0/eps))).*sqrt(offset(1));
% ampsyn=(ampsyn.*exp(-x.*offset.*0.5.*sqrt(mu0/eps)))./sqrt(offset);
% ampsyn=(max_fsyn.*(ampexp(1)/max_fsyn(1)).*exp(x.*offset(1).*0.5.*sqrt(mu0/eps)))*offset(1);

%2D
% ampsyn=(A0.*exp(-sigma.*offset.*0.5.*sqrt(mu0/eps)))./(offset);
%3D
ampsyn=(A0.*exp(-sigma.*offset.*0.5.*sqrt(mu0/eps)))./(offset.^2);

% semilogy(offset,ampexp,'k');hold on
% semilogy(offset,ampsyn,'--r');hold off

plot(offset,ampexp,'k','DisplayName','Measured Value','Parent',axis)
hold on
plot(offset,ampsyn,'--r','DisplayName','Estimated Value','Parent',axis)
hold off

err=sum(abs(ampsyn-ampexp).^2)/numel(offset);
cor_factor=ampexp(1)/max_fsyn(1);
%disp([err]);
%save('cor_factor','cor_factor','ampexp','ampsyn');
