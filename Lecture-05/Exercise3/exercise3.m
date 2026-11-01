fs = 200;
T = 1;
t = 0:1/fs:T-1/fs;

d = 3;
f2 = 13.2 + 0.17*d;

x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*f2*t);

N = length(x);
Y = fft(x);

P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = fs*(0:N/2)/N;

figure
plot(f, P1)
grid on
xlabel('Frequency (Hz)')
ylabel('Amplitude')
title('Single-sided amplitude spectrum')
saveas(gcf, 'exercise3_spectrum_1s.png')


%% Four-second recording
T = 4;
t = 0:1/fs:T-1/fs;
x4 = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*f2*t);

N = length(x4);
Y = fft(x4);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:N/2)/N;

figure
plot(f, P1)
grid on
xlabel('Frequency (Hz)'); ylabel('Amplitude')
title('Single-sided amplitude spectrum, T = 4 s')
saveas(gcf, 'exercise3_spectrum_4s.png')

%% Zero-padded one-second recording (x is still the 1 s signal)
N = length(x);          % original length, 200
M = 4*N;                % padded FFT length, 800
Y = fft(x, M);
P2 = abs(Y/N);          % divide by N, not M, to keep the amplitude scale
P1 = P2(1:M/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:M/2)/M;

figure
plot(f, P1)
grid on
xlabel('Frequency (Hz)'); ylabel('Amplitude')
title('Single-sided amplitude spectrum, T = 1 s, zero-padded 4x')
saveas(gcf, 'exercise3_spectrum_zeropad.png')