f = 10;
fs = 1000;

t = 0:0.001:1;
x = sin(2*pi*f*t);

n = 0:1/fs:1;
xs = sin(2*pi*f*n);

figure
plot(t, x, 'b', 'LineWidth', 2)
hold on
stem(n, xs, 'r', 'filled')

grid on
xlabel('Time (s)')
ylabel('Amplitude')
legend('Continuous signal', 'Samples')
title('1000Hz Sampling Rate')
saveas(gcf, 'sampling_1000Hz.png')