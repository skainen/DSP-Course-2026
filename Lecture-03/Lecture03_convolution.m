clear;
close all;
clc;

% Use the same random noise each time
rng(1);

%% Create a clean discrete-time signal

n = 0:100;
clean = sin(0.1*pi*n);

%% Add noise

noise = 0.4*randn(size(n));
measured = clean + noise;

% Multiply the noisy signal by 2

scaleFactor = 2;
scaled = scaleFactor * measured;

%% Display the clean and noisy signals

figure;

plot(n,measured,'Color',[0.6 0.6 0.6]);
hold on;
plot(n, scaled, 'r', 'LineWidth', 1.2);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Amplitude Scaling: Noisy vs. Scaled');
legend('Noisy Signal', 'Scaled Signal');

saveas(gcf, 'signal_operations.png');


%% Task 2: Signal delay

delay = 5;
delayed = [zeros(1,delay) measured];

n_measured = 0:length(measured)-1;
n_delayed  = 0:length(delayed)-1;

figure;
plot(n_measured, measured, 'Color', [0.6 0.6 0.6], 'LineWidth', 1);
hold on;
plot(n_delayed, delayed, 'r--', 'LineWidth', 1.2);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title(sprintf('Signal Delay: Noisy vs. Delayed by %d Samples', delay));
legend('Noisy signal', 'Delayed signal');
xlim([0 n_delayed(end)]);


%% Task 3: Five-point moving-average filter
h5 = ones(1,5)/5;
filtered5 = conv(measured, h5, 'same');

figure;
plot(n, clean, 'b', 'LineWidth', 1.5);
hold on;
plot(n, measured, 'Color', [0.6 0.6 0.6]);
plot(n, filtered5, 'r', 'LineWidth', 1.2);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Five-Point Moving-Average Filter');
legend('Clean signal', 'Noisy signal', '5-point filtered');
saveas(gcf, 'noise_filtering.png');

%% Task 4: Compare two filter lengths
h15 = ones(1,15)/15;
filtered15 = conv(measured, h15, 'same');

figure;
plot(n, clean, 'b', 'LineWidth', 1.5);
hold on;
plot(n, measured, 'Color', [0.7 0.7 0.7]);
plot(n, filtered5, 'r--', 'LineWidth', 1.2);
plot(n, filtered15, 'k-.', 'LineWidth', 1.5);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Moving-Average Filter Comparison: 5-Point vs. 15-Point');
legend('Clean signal', 'Noisy signal', '5-point filtered', '15-point filtered', ...
       'Location', 'best');
saveas(gcf, 'filter_comparison.png');