%% filter_lab.m  -  Part A (sensor LPF: FIR vs IIR) and Part B (50 Hz hum band-stop)
clear; close all; clc;

%% ===================== PART A =====================
Fs = 1000;
t  = (0:1/Fs:2-1/Fs)';
rng(7);
clean = sin(2*pi*5*t) + 0.35*sin(2*pi*12*t);
noise = 0.35*sin(2*pi*50*t) + 0.20*sin(2*pi*137*t) + 0.25*randn(size(t));
x = clean + noise;

fc = 20;
bFIR = fir1(60, fc/(Fs/2), 'low');              % 61 taps, Hamming window
[bIIR,aIIR] = butter(4, fc/(Fs/2), 'low');      % 5 b + 5 a coefficients
yFIR = filtfilt(bFIR, 1, x);
yIIR = filtfilt(bIIR, aIIR, x);

% --- A1: time domain, 0.2 s window, shared axes
idx = t >= 0.9 & t < 1.1;
figure('Name','A1 time');
plot(t(idx), x(idx), 'Color',[.75 .75 .75]); hold on;
plot(t(idx), clean(idx), 'k', 'LineWidth',2);
plot(t(idx), yFIR(idx), 'b--', 'LineWidth',1.3);
plot(t(idx), yIIR(idx), 'r-.', 'LineWidth',1.3);
grid on; xlabel('Time (s)'); ylabel('Amplitude');
legend('Noisy','Clean','FIR (filtfilt)','IIR (filtfilt)','Location','best');
title('0.2 s section, t = 0.9-1.1 s'); ylim([-2 2]);
saveas(gcf, 'A1_time.png');

% Edge view (filtfilt start-up/end transients)
figure('Name','A1 edges');
subplot(1,2,1); e = t < 0.2;
plot(t(e),clean(e),'k',t(e),yFIR(e),'b--',t(e),yIIR(e),'r-.'); grid on;
title('Start edge'); xlabel('Time (s)'); ylim([-2 2]);
subplot(1,2,2); e = t > 1.8;
plot(t(e),clean(e),'k',t(e),yFIR(e),'b--',t(e),yIIR(e),'r-.'); grid on;
title('End edge'); xlabel('Time (s)'); ylim([-2 2]);
legend('Clean','FIR','IIR');
saveas(gcf, 'A1_edges.png');

% --- A2: magnitude responses (single pass AND effective filtfilt = |H|^2)
nf = 4096;
[HF,f] = freqz(bFIR, 1, nf, Fs);
[HI,~] = freqz(bIIR, aIIR, nf, Fs);
dB = @(H) 20*log10(abs(H) + eps);
figure('Name','A2 freqz');
plot(f, dB(HF),'b', f, dB(HI),'r', 'LineWidth',1.2); hold on;
plot(f, 2*dB(HF),'b:', f, 2*dB(HI),'r:', 'LineWidth',1.2);
xline(fc,'k--','20 Hz cutoff'); xline([50 137],'m:',{'50','137'});
grid on; xlim([0 200]); ylim([-150 5]);
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
legend('FIR single pass','IIR single pass','FIR filtfilt (|H|^2)','IIR filtfilt (|H|^2)','Location','southwest');
title('Low-pass magnitude responses');
saveas(gcf, 'A2_freqz.png');

fprintf('\n--- Filter gain at key frequencies (single pass / filtfilt), dB ---\n');
for fk = [5 12 20 50 137]
    gF = dB(freqz(bFIR,1,[fk fk],Fs)); gI = dB(freqz(bIIR,aIIR,[fk fk],Fs));
    fprintf('%4d Hz  FIR %7.2f / %7.2f   IIR %7.2f / %7.2f\n', fk, gF(1), 2*gF(1), gI(1), 2*gI(1));
end

% --- A3: single-sided amplitude spectra
ss = @(s) local_ss(s);
[fA, Px] = ss(x); [~, PF] = ss(yFIR); [~, PI] = ss(yIIR);
figure('Name','A3 spectra');
semilogy(fA, Px, 'Color',[.6 .6 .6]); hold on;
semilogy(fA, PF, 'b', fA, PI, 'r');
xline([5 12 50 137],'k:',{'5','12','50','137'}); xline(fc,'k--','fc');
grid on; xlim([0 200]); ylim([1e-6 2]);
xlabel('Frequency (Hz)'); ylabel('|X(f)| (single-sided amplitude)');
legend('Noisy','FIR','IIR'); title('Single-sided amplitude spectra');
saveas(gcf, 'A3_spectra.png');

fprintf('\n--- Spectral amplitude at tones (bin-exact: 0.5 Hz resolution) ---\n');
for fk = [5 12 50 137]
    [~,k] = min(abs(fA-fk));
    fprintf('%4d Hz  noisy %.4f  FIR %.4f  IIR %.4f\n', fk, Px(k), PF(k), PI(k));
end

% --- A4: RMSE (full record and with 0.2 s trimmed off each end)
rmse = @(y,m) sqrt(mean((y(m)-clean(m)).^2));
all_ = true(size(t)); mid = t >= 0.2 & t < 1.8;
fprintf('\n--- RMSE vs clean ---\n          full      mid(0.2-1.8 s)\n');
fprintf('noisy   %.4f    %.4f\n', rmse(x,all_),    rmse(x,mid));
fprintf('FIR     %.4f    %.4f\n', rmse(yFIR,all_), rmse(yFIR,mid));
fprintf('IIR     %.4f    %.4f\n', rmse(yIIR,all_), rmse(yIIR,mid));

% Decompose FIR error: how much is passband droop on the 12 Hz component?
H12 = freqz(bFIR, 1, [12 12], Fs);      % two-element vector; use first
fprintf('FIR: predicted 12 Hz amplitude after filtfilt = %.3f (true 0.35)\n', ...
        0.35*abs(H12(1))^2);

%% ===================== PART B =====================
load handel                       % y, Fs (8192 Hz)
FsA = Fs;
assert(FsA > 102, 'Fs too low to represent 50 Hz');
xClean = y(:);                    % (handout has a typo: y( )
tAudio = (0:numel(xClean)-1)'/FsA;
humA   = 0.15;
xHum   = xClean + humA*sin(2*pi*50*tAudio);

edgesN = [49 51]/(FsA/2);  edgesW = [45 55]/(FsA/2);
assert(all(edgesN < 1) && all(edgesW < 1));
[bN,aN] = butter(2, edgesN, 'stop');      % 4th-order band-stop
[bW,aW] = butter(2, edgesW, 'stop');
yAudio = filtfilt(bN, aN, xHum);
yWide  = filtfilt(bW, aW, xHum);

% --- B1: waveforms, shared axes
seg = tAudio >= 2.0 & tAudio < 2.2;
figure('Name','B1 waveform');
subplot(3,1,1); plot(tAudio(seg), xClean(seg)); title('Clean'); grid on;
subplot(3,1,2); plot(tAudio(seg), xHum(seg));   title('+ 50 Hz hum'); grid on;
subplot(3,1,3); plot(tAudio(seg), yAudio(seg)); title('Filtered (49-51 Hz stop)'); grid on;
xlabel('Time (s)'); linkaxes(findobj(gcf,'Type','axes'),'xy'); ylim([-1 1]);
saveas(gcf, 'B1_waveform.png');

% --- B2: spectra (1 s Welch window -> ~1 Hz resolution) + spectrograms
win = hann(FsA); nov = FsA/2; nfft = 4*FsA;
[Pc,fw] = pwelch(xClean, win, nov, nfft, FsA);
Ph = pwelch(xHum,  win, nov, nfft, FsA);
Pn = pwelch(yAudio,win, nov, nfft, FsA);
Pw = pwelch(yWide, win, nov, nfft, FsA);
figure('Name','B2 PSD');
plot(fw,10*log10(Pc),'k', fw,10*log10(Ph),'r', fw,10*log10(Pn),'b', fw,10*log10(Pw),'g');
xline(50,'m--','50 Hz hum'); grid on; xlim([0 200]);
xlabel('Frequency (Hz)'); ylabel('PSD (dB/Hz)');
legend('Clean','Hum added','Filtered 49-51','Filtered 45-55');
saveas(gcf, 'B2_psd.png');

figure('Name','B2 spectrogram');
sigs = {xClean, xHum, yAudio}; names = {'Clean','Hum added','Filtered 49-51 Hz'};
for k = 1:3
    subplot(1,3,k);
    spectrogram(sigs{k}, hann(4096), 3072, 8192, FsA, 'yaxis');
    ylim([0 0.3]); clim([-120 -20]); title(names{k});   % 0-300 Hz (axis in kHz)
end
saveas(gcf, 'B2_spectrogram.png');

% --- B3: playback, identical gain
g = 0.9/max(abs(xHum));
disp('Playing hum-added...');     sound(g*xHum,   FsA); pause(numel(xHum)/FsA + 1);
disp('Playing filtered 49-51...'); sound(g*yAudio, FsA); pause(numel(xHum)/FsA + 1);
disp('Playing filtered 45-55...'); sound(g*yWide,  FsA); pause(numel(xHum)/FsA + 1);

% --- B4: 50 Hz amplitude, least-squares sinusoid fit (handles non-integer bin)
A50 = @(s) local_tone_amp(s, tAudio, 50);
fprintf('\n--- 50 Hz amplitude (LS fit of sin+cos at 50 Hz over whole record) ---\n');
fprintf('clean           %.5f\n', A50(xClean));
fprintf('hum added       %.5f\n', A50(xHum));
fprintf('filtered 49-51  %.5f  (residual hum %.2e)\n', A50(yAudio), A50(yAudio - xClean));
fprintf('filtered 45-55  %.5f  (residual hum %.2e)\n', A50(yWide),  A50(yWide  - xClean));
% steady-state region only (exclude filtfilt transients, ~1 s each end)
ssM = tAudio > 1 & tAudio < tAudio(end)-1;
fprintf('residual hum, steady state: narrow %.2e, wide %.2e\n', ...
    local_tone_amp(yAudio(ssM)-xClean(ssM), tAudio(ssM), 50), ...
    local_tone_amp(yWide(ssM)-xClean(ssM),  tAudio(ssM), 50));

% Filter response cross-check
[HN,fN] = freqz(bN,aN,2^16,FsA); [HW,~] = freqz(bW,aW,2^16,FsA);
figure('Name','B4 notch response');
plot(fN,2*dB(HN),'b',fN,2*dB(HW),'g','LineWidth',1.2); grid on;
xlim([30 70]); ylim([-120 5]); xline(50,'m--');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB), filtfilt = |H|^2');
legend('49-51 Hz','45-55 Hz'); title('Band-stop responses (effective)');
saveas(gcf, 'B4_notch_response.png');

% --- B5: what the wide stop band removes from the music itself
fprintf('\n--- Collateral damage (error vs clean, steady state) ---\n');
fprintf('RMS(yNarrow - clean) = %.2e\n', rms(yAudio(ssM)-xClean(ssM)));
fprintf('RMS(yWide   - clean) = %.2e\n', rms(yWide(ssM) -xClean(ssM)));
band = @(P,lo,hi) 10*log10(sum(P(fw>=lo & fw<=hi)));
sideE = @(P) 10*log10(10^(band(P,44,48.5)/10) + 10^(band(P,51.5,56)/10));
fprintf('Music energy in 44-48.5 + 51.5-56 Hz: clean %.1f dB, narrow %.1f dB, wide %.1f dB\n', ...
    sideE(Pc), sideE(Pn), sideE(Pw));

%% ===================== local functions =====================
function [f, P1] = local_ss(s)
    N = numel(s); Fs = 1000;
    X = fft(s); P2 = abs(X/N);
    P1 = P2(1:floor(N/2)+1); P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:floor(N/2))'/N;
end

function A = local_tone_amp(s, t, f0)
    M = [sin(2*pi*f0*t) cos(2*pi*f0*t) ones(size(t))];
    c = M \ s(:);
    A = hypot(c(1), c(2));
end