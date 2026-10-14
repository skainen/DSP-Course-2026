% Discrete-time amplitude scaling example
n = 0:20;
x = sin(0.3*pi*n);
A1 = 2;
A2 = 0.5;
y1 = A1 * x;
y2 = A2 * x;
figure
stem(n, x, 'filled', 'DisplayName', 'x[n]'); hold on
stem(n, y1, 'filled', 'DisplayName', '2x[n]');
stem(n, y2, 'filled', 'DisplayName', '0.5x[n]');
grid on
xlabel('n')
ylabel('Amplitude')
title('Discrete-Time Amplitude Scaling')
legend('Location', 'best')