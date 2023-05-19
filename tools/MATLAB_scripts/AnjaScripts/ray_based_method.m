clear ,close all; clc;

p          = mfilename('fullpath');
script_dir = fileparts(p);
parent_dir = fullfile(script_dir, '..');
addpath(genpath(parent_dir));

global antsep dt

%file='CS040E';
% file='3mCrossLine';
% suffix='.dt1';

file   = 'synmodel_Busch_singlelayer_ini.out';

hrec=0.005;                 %height receiver [m]
hsource=0.005;              %height source [m]
relerr=1.e-4;               %relative error

% direc_data='..\fwi_data\';
% direc_fig='..\fwi_figures\';
% direc_files='..\fwi_files\';

direc_data = 'C:\OneDrive - Delft University of Technology\4. Semester - Thesis\OutputgprMax';
direc_fig = direc_data;
direc_files = direc_data;

isFFT = true;

loadedData = fft_gprMaxOutput(direc_data, file, isFFT);
fn   = fieldnames(loadedData);

dexp_obs    = loadedData.(fn{1}).Data.fields.Ez;
nsamp       = loadedData.(fn{1}).Attributes.iterations;
ntrace      = loadedData.(fn{1}).Attributes.nrx;
dx0         = loadedData.(fn{1}).Attributes.RxData.Position(1,1) - ...
              loadedData.(fn{1}).Attributes.SrcData.Position(1,1); % x-coordinates
antsep      = loadedData.(fn{1}).Attributes.RxData.Position(:,1) - dx0; % x-coordinates
dx          = unique(round(diff(antsep),7));
dt          = loadedData.(fn{1}).Attributes.dt;
f           = loadedData.(fn{1}).Axis.fAxis;
df          = diff(f(1:2));
t           = loadedData.(fn{1}).Axis.time;
% [dexp_obs,nsamp,ntrace,antsep,dx0,dx,dt,f,df,t]=read_experimental(direc_data,file,suffix);

for ntr=1:ntrace
    scale_dexp_obs(:,ntr)=dexp_obs(:,ntr)./max(dexp_obs(:,ntr));
end

[clp clpt]=find(max(abs(dexp_obs))>=max(max(abs(dexp_obs))));


h1=figure;
subplot(121);
    imagesc(scale_dexp_obs);
    xlabel('Traces');
    ylabel('Samples');
    title('exp. data')
    caxis([-0.5 1])
subplot(122);plot(max(abs(dexp_obs)));
    title(['last clipped trace: ',num2str(max(clpt)),' at ',num2str(antsep(max(clpt))),' m']);    
    set(h1,'position',[0 0, 800 550])
    set(h1,'PaperPositionMode','Auto')
    title('max. amplitude')
    
    print -depsc -r1200 CMP


trainv=1:1:ntrace;
%trainv=1:1:70;
freqinv=1:nsamp/2;
[fdexp,dexp,NaN_mat_all,cfreq,tap_mute,dexp_bp]=pre_processing(dexp_obs,ntrace,nsamp,t,f,trainv);

% trainv_cond=5:30;
trainv_cond = trainv;
%close all;

scale_dexp=zeros(size(dexp));
for ntr=1:ntrace
    scale_dexp(:,ntr)=dexp(:,ntr)./max(dexp(:,ntr));
end

figure;
    imagesc(antsep,t,scale_dexp);hold on
    title('dexp');
    xlabel('Offset [m]');
    ylabel('Time [s]');
    set(gca,'xaxislocation','top');
    title ('esimate velocity of reflection')
    caxis([-0.5 1])
    
if exist('vel_picks.mat');
    load('vel_picks.mat');
else
   % [xx tt]=ginput(2);
    fprintf('Please select two points\n')
     [xx tt]=ginput(2);     
    save('vel_picks','xx','tt');
end

t1=tt(1);
x1=xx(1);
t2=tt(2);
x2=xx(2);

m=(t2-t1)/(x2-x1);
y0=(x2*t1-x1*t2)/(x2-x1);
pck=((m.*antsep)+y0);
vel=1/m;
plot(antsep,pck,'--k','linewidth',2);

disp(['velocity [m/s]: ',num2str(vel)]);
disp(['velocity [m/ns]: ',num2str(vel./1e9)]);   
perm=(299792458/vel).^2;
disp(['permittivity: ',num2str(perm)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cond_pre=0;
[cond,cor_factor]=far_field_approx(dexp(:,trainv_cond),antsep(trainv_cond),nsamp,perm,cond_pre);
disp(['conductivity: ',num2str(cond+cond_pre)]);

fprintf('Saving at %sray_based_results...', direc_files)
ray_based_results=[perm cond+cond_pre];
save([direc_files 'ray_based_results'],'ray_based_results');
fprintf('Done\n')