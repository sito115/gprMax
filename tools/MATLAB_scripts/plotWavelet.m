clear
close all
%% Input

freq = 92e6;
tStart  = -1e-8;
tEnd    = 4e-8;
lw = 2;

fcut = 3e8;

n        = 17;
nSamples = 2^n;
nonZeroThresh = 1e-3;
%% Initial wavelet (gaussian)
t = (tEnd-tStart);
dt = t/nSamples;
tVector = tStart + dt*(0:nSamples-1);

zeta    =   2*pi^2*freq.^2;
chi     = 1./freq;
w       = exp(-zeta*(tVector-chi).^2);

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
plot(tVector, w, 'LineWidth', lw)
title('Initial Wavelet')
grid on

wPlot = nexttile;
plot(tVector, wHat, 'LineWidth', lw)
title('First Derivative Wavelet')
grid on

wwPlot = nexttile;
findpeaks(wHatHat)
plot(tVector,wHatHat, 'LineWidth', lw)
title('Second Derivative Wavelet')
grid on
xlabel('times (s)')

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
plot(fAxis, DataNorm(abs(w_fft(1:numel(fAxis))), scale) , 'LineWidth', lw)
title('FFT Initial Wavelet')
grid on
xlim([0 fcut])

[~, idxmaxFreq] = max(abs(w_fft(1:numel(fAxis))));
fprintf('0nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

wPlotfft = nexttile;
plot(fAxis, DataNorm(abs(wHat_fft(1:numel(fAxis))), scale), 'LineWidth', lw)
title('FFT First Derivative Wavelet')
grid on
xlim([0 fcut])

[~, idxmaxFreq] = max(abs(wHat_fft(1:numel(fAxis))));
fprintf('1nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

wwPlotfft = nexttile;
plot(fAxis, DataNorm(abs(wHatHat_fft(1:numel(fAxis))), scale), 'LineWidth', lw)
title('FFT Second Derivative Wavelet')
grid on
xlabel('frequency (Hz)')
xlim([0 fcut])

[~, idxmaxFreq] = max(abs(wHatHat_fft(1:numel(fAxis))));
fprintf('2nd derivative: max freq at %e Hz\n', fAxis(idxmaxFreq))

title(t,sprintf('Gaussian wavelet with %.2e center frequency and %.1f samples', freq ,nSamples))

%% First break
[firstBreak,firstMinimum,maxAmplitude] = find1stBreak(-wHatHat', tVector', nonZeroThresh);

deltaT = maxAmplitude - firstBreak;
fprintf('Delta T = %e s\n', deltaT)


