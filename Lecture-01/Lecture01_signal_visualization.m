clear; close all; clc;

%% Common parameters
fs = 1000;              % sampling frequency [Hz]
duration = 1;           % [s]
t = 0:1/fs:duration;    % time vector [s]
 
%% Task 1: Single sine wave
A = 1;                  % amplitude
f = 5;                  % frequency [Hz]
y = A * sin(2*pi*f*t);

fig1 = figure('Name', 'Task 1: Sine wave');
plot(t, y, 'LineWidth', 1.5);
title('Sine Wave: A = 1, f = 5 Hz');
xlabel('Time [s]');
ylabel('Amplitude');
grid on;

%% Task 2: Compare different frequencies
freqs = [2 5 10];       % [Hz]

fig2 = figure('Name', 'Task 2: Frequency comparison');
for k = 1:numel(freqs)
    subplot(numel(freqs), 1, k);
    plot(t, sin(2*pi*freqs(k)*t), 'LineWidth', 1.5);
    title(sprintf('f = %d Hz (A = 1)', freqs(k)));
    xlabel('Time [s]');
    ylabel('Amplitude');
    ylim([-1.2 1.2]);
    grid on;
end
sgtitle('Frequency Comparison');

%% Task 3: Compare different amplitudes (same frequency)
amps = [0.5 1 2];
f = 5;                  % [Hz]
 
fig3 = figure('Name', 'Task 3: Amplitude comparison');
for k = 1:numel(amps)
    subplot(numel(amps), 1, k);
    plot(t, amps(k)*sin(2*pi*f*t), 'LineWidth', 1.5);
    title(sprintf('A = %.1f (f = %d Hz)', amps(k), f));
    xlabel('Time [s]');
    ylabel('Amplitude');
    ylim([-2.2 2.2]);   % same y-axis on all plots so amplitudes are comparable
    grid on;
end
sgtitle('Amplitude Comparison');

%% Task 4: Add noise
rng(0);                          % fixed seed -> reproducible noise
clean = sin(2*pi*5*t);
noiseLevel = 0.3;                % standard deviation of the noise
noisy = clean + noiseLevel * randn(size(t));
 
fig4 = figure('Name', 'Task 4: Clean vs noisy');
subplot(2, 1, 1);
plot(t, clean, 'LineWidth', 1.5);
title('Clean Signal (5 Hz)');
xlabel('Time [s]');
ylabel('Amplitude');
ylim([-2 2]);
grid on;
 
subplot(2, 1, 2);
plot(t, noisy);
title(sprintf('Noisy Signal (Gaussian noise, \\sigma = %.1f)', noiseLevel));
xlabel('Time [s]');
ylabel('Amplitude');
ylim([-2 2]);
grid on;
sgtitle('Clean vs Noisy Signal');
 
%% Task 5: Save figures as PNG
saveas(fig1, 'sine_wave.png');
saveas(fig2, 'frequency_comparison.png');
saveas(fig3, 'amplitude_comparison.png');
saveas(fig4, 'clean_vs_noisy_signal.png');

 
disp('Figures saved to the current folder.');
