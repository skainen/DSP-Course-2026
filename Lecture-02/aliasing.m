f = 15; % Signal frequency
fs = 20; % Sampling frequency
t = 0:0.001:1;
x = sin(2*pi*f*t);
n = 0:1/fs:1;
xs = sin(2*pi*f*n);
plot(t,x,'b','LineWidth',2)
hold on
stem(n,xs,'r','filled')
grid on
xlabel('Time (s)')
ylabel('Amplitude')
legend('Original Signal','Samples')
title('Aliasing Example')