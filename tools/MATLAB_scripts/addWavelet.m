function allData = addWavelet(allData,timePlot, freqPlot, component, nonZeroThresh, lw)

nField = numel(fieldnames(allData));



colors = distinguishable_colors(nField+1);
color  = colors(end,:); 

% Dialog
prompt = {'Start [s]','End [s]', 'Frequency [Hz]', 'Samples n for 2^n','Identifier','Scaling Time'};
answer = inputdlg(prompt','Define Parameters',[1 150],{'0', '5e-8', '92e6', '12','MyMexicanHat','10e-4'});

tStart      = str2double(answer{1});
tEnd        = str2double(answer{2});
freq        = str2double(answer{3});
n           = str2double(answer{4});
identifier  = answer{5};
scalingTime     = str2double(answer{6});
nSamples = 2^n;

fprintf('%s\n',identifier)

fieldName = erase(identifier,{'.','-','_',' ','(',')','[',']'});
%% Initial wavelet (gaussian)
t = (tEnd-tStart);
dt = t/nSamples;
tVector = tStart + dt*(0:nSamples-1);

zeta    =   2*pi^2*freq.^2;
chi     = 1./freq;
w       = exp(-zeta*(tVector-chi).^2);

%% FFT
w_fft    = fft(w);
omega    = (2*pi/t) * [0:nSamples/2-1, 0, -nSamples/2+1:-1];
% omega    = fftshift(omega);
wHat_fft = 1i*omega.*w_fft;
wHatHat_fft = 1i * omega.*wHat_fft;
wHat        = ifft(wHat_fft);
wHatHat     = -ifft(wHatHat_fft);
wHatHat     = (scalingTime/max(abs(wHatHat))) * wHatHat;
wHatHat_fft = fft(wHatHat)*dt;
%% Add to allData
allData.(fieldName).Data.fields.(component) = wHatHat;
allData.(fieldName).Axis.time               = tVector;

%% Plot

df    = 1/(dt*nSamples);
fAxis = linspace(0,nSamples/2,fix(nSamples/2+1))*df;    %making the frequency axis

tLine = plot(tVector,wHatHat , ':', 'DisplayName',identifier,...
               'LineWidth', lw, 'Parent',timePlot,'Color',color);
tLine.UserData.ShowLine = 1;
tLine.UserData.Color = color;

fLine = plot(fAxis, abs(wHatHat_fft(1:numel(fAxis)))  ,...
                                ':', 'DisplayName',identifier,...
                                'LineWidth', lw, 'Parent',freqPlot,'Color',color);
fLine.UserData.ShowLine = 1;
fLine.UserData.Color = color;
%% Add Firstbreak
[pks,locs] = findpeaks(-wHatHat, 'MinPeakProminence',0.1*max(abs(wHatHat)));

fprintf('\t\tFirst local minumum found at %e having a value of %e\n', tVector(locs(1)), pks(1) )

threshold   = pks(1) * nonZeroThresh;
idx         = find(abs(wHatHat)>threshold,1);

fprintf('\t\tNew threshold is %f %% above the first local minimum for absolute values\n', nonZeroThresh*100)

if isempty(idx)
    firstBreak = -1e-9;
    warning('\tNo value above threshold\n')
    fprintf('\tFirst break set at %e s\n', firstBreak)
else
    firstBreak = tVector(idx(1));
    fprintf('\tFirst break above threshold %.2e at %e s\n', threshold, firstBreak)
end

[~, idx] = max(abs(wHatHat_fft(1:numel(fAxis))));
fmax = fAxis(idx);
fprintf('Dominant Frequency at %e Hz\n',fmax)

allData.(fieldName).FirstBreak = firstBreak;
allData.(fieldName).Color      = color;

end