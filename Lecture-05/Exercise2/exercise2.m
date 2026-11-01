fs = 200;
T = 1;
t = 0:1/fs:T-1/fs;

x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*40*t);

figure
plot(t, x)
grid on
xlabel('Time (s)'); ylabel('Amplitude')
title('Signal in time domain')
saveas(gcf, 'exercise2_timedomain.png')

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
saveas(gcf, 'exercise2_spectrum.png')