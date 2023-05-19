function[sigma1_estimation,cor_factor]=far_field_approx(dexp_data,offset,nsamp,perm,cond_pre)

max_dexp_data=max(abs(dexp_data));
   
x0=1e-1;
xm=1e-8;
mu0=4*pi*1e-7;
eps=perm*8.88542e-12;  

max_dsyn_data=(max(max_dexp_data));%.*exp(-cond_pre.*offset.*(sqrt(mu0/eps)/2)))./(offset.^2);

figure
plot(max_dexp_data,'b');hold on
plot(max_dsyn_data,'r');hold on

%estimation of sigma1 based on the amplitudes of max_fdexp%%%%%%%%%%%%%
    
figure;
[sigma1_estimation]=fminbnd(@(x)procconstraint_sigma1_estimation(x,max_dexp_data,max_dsyn_data,offset,mu0,eps),xm,x0);
title('fitting cond.')

save('sigma1_estimation','sigma1_estimation');
load('cor_factor.mat');    