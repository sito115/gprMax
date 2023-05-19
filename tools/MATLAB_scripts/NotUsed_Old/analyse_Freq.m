%% Select Path
clear, clc, close all

pathRoot = 'C:\OneDrive - Delft University of Technology\3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax';
[filename, pathname, check] = uigetfile([pathRoot '\*.out'], 'Select gprMax output file to plot B-scan', 'MultiSelect', 'on');
assert(check ~= 0, 'No File Selected')

filename = fullfile(pathname, filename);

%% Setup Parameters
fieldComponent = 'Ex';
assert(ismember(fieldComponent, {'Ex' 'Ey' 'Ez'}), 'Unknown field component');

fs           = 10;
lw           = 2;
fcut         = 1e9;
isNormalize  = true;
isFilterFreq = true;
isFilterTime = false;
%% Open file and read fields
iterations = double(h5readatt(filename, '/', 'Iterations'));
dt         = h5readatt(filename, '/', 'dt');
dx         = 0.025; %h5readatt(filename, '/', 'dx_dy_dz'); 

if isempty(fieldComponent)
    prompt      = 'Which field do you want to view? Ex, Ey, or Ez: ';
    fieldComponent       = input(prompt,'s');
end

fieldpath   = strcat('/rxs/rx1/', fieldComponent);
fieldRaw    = h5read(filename, fieldpath)';
time        = linspace(0, (iterations - 1) * dt, iterations)';
traces      = 0:size(fieldRaw, 2);
nTime       = size(fieldRaw, 1);
nX          = size(fieldRaw, 2);

%% Plot Raw and Normalised Data

if isNormalize
    tempField = fieldRaw ./ max(fieldRaw);
    figure
    imagesc(traces,time,tempField(:,:))
    colorbar
    xlabel('Traces','Fontsize',fs)
    ylabel('Traveltime (s)','Fontsize',fs)
    title('Normalised - Reflection data','Fontsize',fs)
    set(gca,'Fontsize',fs)
    set(gca,'LineWidth',lw)
end

figure %Raw
imagesc(traces,time,fieldRaw(:,:))
colorbar
xlabel('Traces','Fontsize',fs)
ylabel('Traveltime (s)','Fontsize',fs)
title('Raw - Reflection data','Fontsize',fs)
set(gca,'Fontsize',fs)
set(gca,'LineWidth',lw)

if isFilterTime
    hold on
    [fig, BW] = localGet_bwMatrix(1:nX, time);

    fieldRawFilter     = fieldRaw;
    fieldRawFilter(BW) = 0;

    figure % Raw Filtered
    imagesc(traces,time,fieldRawFilter(:,:))
    colorbar
    xlabel('Traces','Fontsize',fs)
    ylabel('Traveltime (s)','Fontsize',fs)
    title('Time Filter - Reflection data','Fontsize',fs)
    set(gca,'Fontsize',fs)
    set(gca,'LineWidth',lw)

    tempField = fieldRawFilter ./ max(fieldRawFilter);

    figure % Raw normalised Filtered
    imagesc(traces,time,tempField(:,:))
    colorbar
    xlabel('Traces','Fontsize',fs)
    ylabel('Traveltime (s)','Fontsize',fs)
    title('Normalised Time Filter - Reflection data','Fontsize',fs)
    set(gca,'Fontsize',fs)
    set(gca,'LineWidth',lw)
end

%% convert to freq domain
fieldRaw_f  = fft(fieldRaw,[],1)*dt;
df          = 1/(nTime*dt);                  %the frequency sampling in Hertz
nFreq       = nTime;                         %the number of frequency samples
freqaxis    = linspace(0,nFreq/2,nFreq/2+1)*df;    %making the frequency axis

fcutel      = find(freqaxis>=fcut,1,'first'); %the new frequency axis
if isempty(fcutel)
    fcutel = numel(freqaxis); 
end

fieldRaw_f = fieldRaw_f(1:fcutel,:);
freqaxis   = freqaxis(1:fcutel);
%% plot freq-space domain
figure
imagesc(traces,freqaxis,abs(fieldRaw_f(:,:)));
colorbar
xlabel('Traces','Fontsize',fs)
ylabel('Frequency (Hz)','Fontsize',fs)
title('Reflection data in the frequency domain - Amplitude','Fontsize',fs)
set(gca,'Fontsize',fs)
set(gca,'LineWidth',lw)

%% Wavenumber domain

fieldRaw_fk   = fftshift(nX*ifft(fieldRaw_f,[],2)*dx,2);
dk            = 1/(nX*dx);              %the wavenumber sampling in 1/m
nk            = nX;                     %the number of wavenumber samples
kaxis         = linspace(-nk/2,nk/2-1,nk)*dk;


%% plot freq-k domain
figure
imagesc(kaxis,freqaxis,abs(fieldRaw_fk(:,:)))
colorbar
xlabel('Wavenumber (1/m)','Fontsize',fs)
ylabel('Frequency (Hz)','Fontsize',fs)
title('Reflection data in the frequency-wavenumber domain','Fontsize',fs)
set(gca,'Fontsize',fs)
set(gca,'LineWidth',lw)

if isFilterFreq
    hold on
    
    [fig, BW] = localGet_bwMatrix(kaxis, freqaxis);
    % set region to zero
    fieldFiltered_fk = fieldRaw_fk;
    fieldFiltered_fk(BW)  = 0;
    %% Display Selected Region to be tapered to 0

    figure
    imagesc(kaxis,freqaxis,abs(fieldFiltered_fk(:,:)))
    colorbar
    xlabel('Wavenumber (1/m)','Fontsize',fs)
    ylabel('Frequency (Hz)','Fontsize',fs)
    title('Filtered Reflection data in the frequency-wavenumber domain','Fontsize',fs)
    set(gca,'Fontsize',fs)
    set(gca,'LineWidth',lw)
    
    %% Transform back 
    %Transforming the data back to the frequency-space domain
    %Adding zeroes in stead of the removed frequencies to obtain time-domain
    
    tempfdata           = fft(fftshift(fieldFiltered_fk,2),[],2)*dk;
    addfreq             = zeros(nFreq,nX);
    addfreq(1:fcutel,:) = tempfdata;
    
    %Transforming the data back to the time-space domain
    fieldFiltered=2*real(nFreq*ifft(addfreq,[],1)*df);
    
    %% Plot Transformed Data
    figure
    imagesc(traces,time,fieldFiltered(:,:))
    colorbar
    xlabel('Traces','Fontsize',fs)
    ylabel('Traveltime (s)','Fontsize',fs)
    title('F-k filtered reflection data','Fontsize',fs)
    set(gca,'Fontsize',fs)
    set(gca,'LineWidth',lw)
    
    %% Trace Normalised
    if isNormalize
        fieldFiltered = fieldFiltered ./ max(fieldFiltered);
        clims = [-1, 1];
        figure
        imagesc(traces,time,fieldFiltered(:,:))
        colorbar
        xlabel('Traces','Fontsize',fs)
        ylabel('Traveltime (s)','Fontsize',fs)
        title('Normalised - F-k filtered reflection data','Fontsize',fs)
        set(gca,'Fontsize',fs)
        set(gca,'LineWidth',lw)
    end
    
end


%%%%%%%%%%%%%%%% LOCAL FUNCTION

%% ginpit
function [fig, BW] = localGet_bwMatrix(xAxis, yAxis)

    assert(numel(xAxis)>1,'Input 1 must be an array > 1')
    assert(numel(yAxis)>1,'Input 1 must be an array > 1')

    button = 1;
    filterX = [];
    filterY = [];
    while button == 1
        [newX, newY, button] = ginput(1);
        if button == 1
           filterX = [filterX; newX];
           filterY = [filterY; newY];
           scatter(newX, newY, 'filled', 'r')
        end
    end
    
    if ~isempty(filterY)
        filterYindex = zeros(size(filterY));
        filterXindex = zeros(size(filterX));
        
        for index = 1:numel(filterX)
           tempY = find(yAxis >= filterY(index), 1, 'first');
           tempX = find(xAxis >= filterX(index), 1, 'first');
           if isempty(tempX)
              tempX = 1;  
           end
    
           filterYindex(index) = tempY;
           filterXindex(index) = tempX;
        end
        
        % close polygon
        filterXindex(end+1) = filterXindex(1);
        filterYindex(end+1) = filterYindex(1);
        
        BW = poly2mask(filterXindex,filterYindex,numel(yAxis),numel(xAxis));
    
        % plot
        fig = figure;
        imshow(BW)
        hold on
        plot(filterXindex,filterYindex,'b','LineWidth',2)
        hold off
    else
        BW = ones(numel(yAxis),numel(xAxis));
        fig = figure;
        imshow(BW)
    end

end