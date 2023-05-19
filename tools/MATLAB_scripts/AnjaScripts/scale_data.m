function[scale_data]=scale_data(data,nsamp,ntrace,filter_length,max_scale)


data_env=zeros(nsamp,ntrace);
env_smooth=zeros(nsamp,ntrace);
env_norm=zeros(nsamp,ntrace);
scale_data=zeros(nsamp,ntrace);

for ntr=1:ntrace
    data_env(:,ntr)=abs(hilbert(data(:,ntr)));
    env_smooth(:,ntr)=smooth(data_env(:,ntr),filter_length);
    env_scale=max(max(env_smooth(:,1:ntr)));
    env_norm(:,ntr)=env_smooth(:,ntr)./env_scale;
    a=find(env_norm(:,ntr)<(1/max_scale));
    env_norm(a,ntr)=1/max_scale;
    scale_data(:,ntr)=data(:,ntr)./env_norm(:,ntr);
end
    
