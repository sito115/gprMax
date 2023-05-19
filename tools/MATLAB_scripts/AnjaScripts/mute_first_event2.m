function[dexp_mute,tap_exp]=mute_first_event2(dexp_obs,ntrace,nsamp,t,trainv)

script_path = mfilename('fullpath');
script_dir = fileparts(script_path);

mode=5;
% 0 = hyperbel 
% 1 = straight line
% 5 = straight line (air)

traces=1:ntrace;
taplen=10;    
scale_mode=0;

scale_dexp_obs=zeros(size(dexp_obs));
if scale_mode==1;
    for ntr=1:ntrace
        scale_dexp_obs(:,ntr)=dexp_obs(:,ntr)./max(dexp_obs(:,ntr));
	end
else
	filter_length=10;
    max_scale=nsamp/2;
    [scale_dexp_obs]=scale_data(dexp_obs,nsamp,ntrace,filter_length,max_scale);
end

if exist('muting1_picksDummy.mat') %exist('muting1_picks.mat');
    load('muting1_picks.mat');
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              
    figure;
    subplot(2,4,[1 2 5 6]);
        imagesc(scale_dexp_obs);
        title('mute first event');
        xlabel('Traces');
        ylabel('Samples');
        set(gca,'xaxislocation','top');
        hold on
       
        fprintf('Please select 2 points\n')
        [trace time]=ginput(2);
        l1=line([round(trace(1)) round(trace(1))],[1 nsamp]);
        l2=line([round(trace(2)) round(trace(2))],[1 nsamp]);
        
    subplot(2,4,[3 7]);
        plot(scale_dexp_obs(:,round(trace(1))));
        set(gca,'view',[90 -270]);
        title(['trace ', num2str(round(trace(1)))]);
        grid on;
    subplot(2,4,[4 8]);   
        plot(scale_dexp_obs(:,round(trace(2))));
        set(gca,'view',[90 -270]);
        title(['trace ', num2str(round(trace(2)))]);
        grid on
         
    fprintf('Please press any key\n')    
    pause
    
    fprintf('Please select 2 points\n')
    [ta xa ]=ginput(2);  % Anja: xa und ta getauscht damit line verschoben!

    ta0=xa(1);
    xa0=round(trace(1));
    tan=xa(end);
    xan=round(trace(2));
    save('muting1_picks','ta0','xa0','tan','xan');
end    

if mode==0;
    vel=sqrt(xan.^2/(tan.^2-ta0.^2));
    Ta=round(sqrt((ta0.^2)+((traces.^2)/(vel.^2))));
elseif mode==1;
    m=(tan-ta0)/(xan-xa0);
    ya=(xan*ta0-xa0*tan)/(xan-xa0);
    Ta=round((m.*traces)+ya);
elseif mode==5;
    ma=(tan-ta0)/(xan-xa0);
    ya=(xan*ta0-xa0*tan)/(xan-xa0);
    Ta=round((ma.*traces)+ya); 
end

figure;
imagesc(scale_dexp_obs);hold on
    title('mute first event');
    xlabel('Traces');
    ylabel('Samples');
    set(gca,'xaxislocation','top');
    
    plot(traces,Ta,'k','linewidth',2);hold on
    
    
tap_exp=zeros(nsamp,ntrace);

dexp_mute=zeros(size(dexp_obs));
if mode==0 || mode==1;
    for ntr=1:ntrace
        fall=Ta(ntr);
        high=Ta(ntr)+taplen;
        tap=transpose([ones(1,fall) 0.5*(1+cos(pi/(high-fall+1)*(1:high-fall+1))) zeros(1,nsamp-(high+1))]);
        dexp_mute(:,ntr)=dexp_obs(:,ntr).*tap(1:nsamp,1);
        tap_exp(:,ntr)=tap(1:nsamp,1);
        plot(traces,Ta+taplen,'--k','linewidth',2);
    end
elseif mode==5
    for ntr=1:ntrace
        low=Ta(ntr)-taplen;
        rise=Ta(ntr);
        
        tap=ones(nsamp,1);
        tap_ones=[zeros(1,low) 0.5*(1-cos(pi/(double(rise)-(double(low)))*(1:double(rise)-(double(low))))) ];

        tap(1:length(tap_ones))=transpose(tap_ones);
        dexp_mute(:,ntr)=dexp_obs(:,ntr).*tap(1:nsamp,1);
        tap_exp(:,ntr)=tap(1:nsamp,1);
        plot(traces,Ta-taplen,'--k','linewidth',2);
    end 
end


%plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

  
    scale_dexp_mute=zeros(size(dexp_obs));
    for ntr=1:ntrace
        scale_dexp_mute(:,ntr)=dexp_mute(:,ntr)./max(dexp_mute(:,ntr));
    end
    
    f = figure;
    subplot(121, 'Parent',f)

    imagesc(scale_dexp_mute)
    hold on
    title('mute first event');
    xlabel('Traces');
    ylabel('Samples');
    set(gca,'xaxislocation','top'); 
    for off=1:length(trainv)
        line([trainv(off) trainv(off)],[0 nsamp]);
    end
    ax = subplot(122, 'Parent',f);
    for off=1:length(trainv)
        plot(scale_dexp_mute(:,trainv(off))+double(trainv(off)),'r','Parent',ax)
        hold on
        xlabel('Samples');
        ylabel('Traces');
        axis tight;
        axis 'auto y';
    end      
    set(gca,'view',[90 -270]);
    set(gca,'xaxislocation','top');
    set(gca,'yaxislocation','right');
save(fullfile(script_dir,'tap_exp'),'tap_exp');