function[expdata,nsamp,ntrace,antsep,dx0,dx,dt,f,df,t]=read_experimental(direc,file,suffix)

filein=[direc file];
cmpfile=[filein,suffix];

switch lower(suffix)
    case('.dzt');
        data=readgssi(cmpfile);
        expdata=fliplr(data.samp);
        [nsamp ntrace]=size(expdata);
        dx0=1/data.head.sps;
        dx=1/data.head.spm;
        nopts=data.head.range;
        antsep=dx0:dx:dx0+(ntrace-1)*dx;
        dt=(nopts/nsamp)*1e-9;
    case('.dt1');
        [expdata,header,ntrace] = EKKO2Dread2_Update(cmpfile);
        nsamp=header(3);
        antsep=header(2,:);
        %nopts=header(9);
        nopts=50;
        dx0=header(2,1);
        dx=diff(antsep(1:2));
        dt=(nopts/nsamp)*1e-9;
end

figure;imagesc(expdata)
f=(0:nsamp-1)/(nsamp*dt);                     
df=diff(f(1:2));
t=(1:nsamp)/(nsamp*df);

caxis([ -2000    2000]);
axis ([0 100 0 150])


disp(['ntrace: ',num2str(ntrace)]);
disp(['nsamp: ',num2str(nsamp)]);
disp(['dx: ',num2str(dx)]);
disp(['dx0: ',num2str(dx0)]);
disp(['dt: ',num2str(dt)]);
disp(['df: ',num2str(df)]);