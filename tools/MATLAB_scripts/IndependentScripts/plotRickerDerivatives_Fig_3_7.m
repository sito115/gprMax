clear

% Plot Ricker wavelet and 1st and 2nd derivative (Fig. 3.7 in Thesis).

% Plot https://docs.gprmax.com/en/latest/plotting.html - gaussian
xlimEnd = 20;
%% Input

freq = 200e6;
tStart  = -1e-8;
tEnd    = 4e-8;
lw = 2;
nanoConverson = 1e9;
megaConversion = 1e-6;
fcut = 600e6;

n        = 17;
nSamples = 2^n;
nonZeroThresh = 1e-3;
%% Initial wavelet (gaussian)
t = (tEnd-tStart);
dt = t/nSamples;
tVector = tStart + dt*(0:nSamples-1);



% Gaussian
% zeta    =   2*pi^2*freq.^2;
% chi     = 1./freq;
% w = exp(-zeta*(tVector-chi).^2);
% Ricker
zeta = pi^2*freq^2;
chi = sqrt(2)/freq;
w = -(2*zeta*(tVector-chi ).^2 - 1 ).*exp(-zeta*(tVector-chi).^2);   

w(1) = 0;
w(end) = 0;
%% FFT
w_fft    = fft(w)*dt;
omega    = (2*pi/t) * [0:nSamples/2-1, 0, -nSamples/2+1:-1];
% omega    = fftshift(omega);
wHat_fft = 1i*omega.*w_fft;
wHatHat_fft = 1i * omega.*wHat_fft;
wHat        = ifft(wHat_fft);
wHatHat     = ifft(wHatHat_fft);

%% Plot Time

figure
t = tiledlayout(3,1);

Plot = nexttile;
% figure
% xlabel('time (ns)')
% title(sprintf('Ricker %dMHz',freq/1e6))
% xlim([0 tVector(end)*nanoConverson])
% set(gca,'FontSize',25)
% title('Initial Wavelet')
plot(tVector*nanoConverson, w, 'LineWidth', lw)
xlim([0 xlimEnd])
grid on

wPlot = nexttile;
plot(tVector*nanoConverson, wHat, 'LineWidth', lw)
title('First Derivative Wavelet')
grid on
xlim([0 xlimEnd])

wwPlot = nexttile;
findpeaks(wHatHat)
plot(tVector*nanoConverson,wHatHat, 'LineWidth', lw)
title('Second Derivative Wavelet')
grid on
xlabel('time (ns)')
xlim([0 xlimEnd])

[pks,locs] = findpeaks(wHatHat,'MinPeakProminence',0.1*max(abs(wHatHat)));
fprintf('2nd derivative: First maximum %e at %e s\n', pks(1), tVector(locs(1)))

title(t,sprintf('Gaussian wavelet with %.2e center frequency and %.1f samples', freq ,nSamples))


%% Plot Frequency
% DataNorm(data, 'db')
scale = 'none';
df    = 1/(dt*nSamples);
fAxis = linspace(0,nSamples/2,fix(nSamples/2+1))*df;    %making the frequency axis


figure
t = tiledlayout(3,1);

Plotfft = nexttile;
% figure
plot(fAxis*megaConversion, DataNorm(abs(w_fft(1:numel(fAxis))), scale) , 'LineWidth', lw)
% xlabel('frequency (MHz)')
% title(sprintf('FFT Ricker %dMHz',freq/1e6))
% set(gca,'FontSize',25)
grid on
xlim([0 fcut*megaConversion])
% title('FFT Initial Wavelet')



[~, idxmaxFreq] = max(abs(w_fft(1:numel(fAxis))));
fprintf('0nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

wPlotfft = nexttile;
plot(fAxis*megaConversion, DataNorm(abs(wHat_fft(1:numel(fAxis))), scale), 'LineWidth', lw)
title('FFT First Derivative Wavelet')
grid on
xlim([0 fcut*megaConversion])

[~, idxmaxFreq] = max(abs(wHat_fft(1:numel(fAxis))));
fprintf('1nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

wwPlotfft = nexttile;
plot(fAxis*megaConversion, DataNorm(abs(wHatHat_fft(1:numel(fAxis))), scale), 'LineWidth', lw)
title('FFT Second Derivative Wavelet')
grid on
xlabel('frequency (MHz)')
xlim([0 fcut*megaConversion])

[~, idxmaxFreq] = max(abs(wHatHat_fft(1:numel(fAxis))));
fprintf('2nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

title(t,sprintf('Gaussian wavelet with %.2e center frequency and %.1f samples', freq ,nSamples))

%% First break
[firstBreak,firstMinimum,maxAmplitude] = find1stBreak(-wHatHat', tVector', nonZeroThresh);

deltaT = maxAmplitude - firstBreak;
fprintf('Delta T = %e s\n', deltaT)


