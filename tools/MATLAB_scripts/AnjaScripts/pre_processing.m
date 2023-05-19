function[fdexp_bp,dexp_bp,NaN_mat_all,cfreq,tap_mute,freqinv,dexp_dc]=pre_processing(dexp_obs,ntrace,nsamp,t,f,trainv)

global antsep dt

%dc shift experimental data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dexp_dc=zeros(nsamp,ntrace);
for ntr=1:ntrace
    dexp_dc(:,ntr)=dexp_obs(:,ntr)-mean(dexp_obs(nsamp-round(nsamp/6):nsamp,ntr));
end
fdexp_dc=fft(dexp_dc);
save('dexp_dc','fdexp_dc','dexp_dc');


%reduce ringing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[dexp_rg]=rem_ringing(dexp_dc,t,ntrace,nsamp);
dexp_rg=dexp_dc;
fdexp_rg=fft(dexp_rg);


%calculate center frequency%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fc pos_fc]=max(mean(abs(fdexp_rg),2));
cfreq=f(pos_fc);

disp(['center frequency fc [MHz]: ',num2str(cfreq/1e6)]);
disp(['center frequency fc [-]: ',num2str(pos_fc)]);
disp(['center frequency ?.??*fc [-]: ',num2str(2),' - ',num2str(f(2)/1e6),' MHz']);
disp(['center frequency 0.25*fc [-]: ',num2str(round(0.25*pos_fc)),' - ',num2str(f(round(0.25*pos_fc))/1e6),' MHz']);
disp(['center frequency 0.5*fc [-]: ',num2str(round(0.5*pos_fc)),' - ',num2str(f(round(0.5*pos_fc))/1e6),' MHz']);
disp(['center frequency 1.5*fc [-]: ',num2str(round(1.5*pos_fc)),' - ',num2str(f(round(1.5*pos_fc))/1e6),' MHz']);
disp(['center frequency 2.0*fc [-]: ',num2str(round(2.0*pos_fc)),' - ',num2str(f(round(2.0*pos_fc))/1e6),' MHz']);
disp(['center frequency 2.5*fc [-]: ',num2str(round(2.5*pos_fc)),' - ',num2str(f(round(2.5*pos_fc))/1e6),' MHz']);
disp(['center frequency 3.0*fc [-]: ',num2str(round(3.0*pos_fc)),' - ',num2str(f(round(3.0*pos_fc))/1e6),' MHz']);
disp(['center frequency 3.5*fc [-]: ',num2str(round(3.5*pos_fc)),' - ',num2str(f(round(3.5*pos_fc))/1e6),' MHz']);

freqinv=7:1:37;


%mute two events seperate%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dexp_mute,tap_first]=mute_first_event2(dexp_rg,ntrace,nsamp,t,trainv);
[dexp_mute,tap_second2]=mute_second_event2(dexp_mute,ntrace,nsamp,t,trainv);

fdexp_mute=fft(dexp_mute);
save('dexp_mute','fdexp_mute','dexp_mute');


if exist('tap_first') && exist('tap_second');
    tap_mute=tap_first.*tap_second;
elseif exist('tap_first') || exist('tap_second');
    tap_mute=tap_first;
elseif exist('tap_second') || exist('tap_first');
    tap_mute=tap_second;
else
    tap_mute=ones(size(dexp_dc));
end


%bandpass filter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [bpfilter_data]=bandpass_filter_data(nsamp,[1 round(0.25*pos_fc) round(3.5*pos_fc) round(4.0*pos_fc)],f);
%  
% for nfr=2:nsamp/2;                         
%      fdexp_bp(nfr,:)=fdexp_mute(nfr,:).*bpfilter_data(nfr,:);
%      fdexp_bp(nsamp-nfr+2,:)=conj(fdexp_bp(nfr,:));
% end
% dexp_bp=ifft(fdexp_bp);

dexp_bp=dexp_mute;
fdexp_bp=fdexp_mute;
save('dexp_bp','fdexp_bp','dexp_bp');

%calculate treshold%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

amplitude_fdexp=zeros(nsamp,ntrace);
treshold=zeros(1,ntrace);
treshold_cutoff=round(3.5*pos_fc):1:nsamp/2;


for ntr=1:ntrace;
    amplitude_fdexp(:,ntr)=abs(fdexp_bp(:,ntr));
    treshold(1,ntr)=mean(amplitude_fdexp(treshold_cutoff,ntr))+std(amplitude_fdexp(treshold_cutoff,ntr));
end

NaN_mat_all=zeros(size(fdexp_bp));
NaN_mat_all(:,:)=NaN;

for ntr=1:ntrace
    th_pos_all=find(abs(fdexp_bp(:,ntr))>=treshold(ntr));
    NaN_mat_all(th_pos_all,ntr)=1;
end


figure       
for off=1:length(trainv);
    plot(t*1e9,1*(dexp_mute(:,trainv(off))/max(dexp_mute(:,trainv(off))))+double(trainv(off)),'k')
    hold on
    plot(t*1e9,1*(dexp_bp(:,trainv(off))/max(dexp_bp(:,trainv(off))))+double(trainv(off)),'r');
    xlabel('Time [ns]');
    ylabel('Traces');
    legend('dc','bp');
    axis tight;
    axis 'auto y';
end
