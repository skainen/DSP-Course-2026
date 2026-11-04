[x,Fs] = audioread('fan_noise/fan_noise.wav');   % straight quote; the ' in yours is a syntax error
if size(x,2) == 2, x = mean(x,2); end

f_guess = [1230 1535 3070 3680 4605 6140 7680];
bw      = 10;
search  = 60;            % refine each guess within ±search Hz

% Refine center frequencies from the data (~2 Hz resolution at 16 kHz)
[P,f] = pwelch(x, 8192, 4096, 8192, Fs);
f0 = zeros(size(f_guess));
for k = 1:numel(f_guess)
    idx = find(abs(f - f_guess(k)) <= search);
    [~,m] = max(P(idx));
    f0(k) = f(idx(m));
end
fprintf('Notching at: %s Hz\n', mat2str(round(f0)));

% Cascade of narrow band-stops
y = x;
for k = 1:numel(f0)
    edges = [f0(k)-bw, f0(k)+bw];
    if edges(2) >= Fs/2
        warning('%.0f Hz is above Nyquist, skipped', f0(k)); continue
    end
    [b,a] = butter(2, edges/(Fs/2), 'stop');
    y = filtfilt(b,a,y);
end

gain = 0.7/max(abs(x));
sound(gain*x,Fs); pause(length(x)/Fs+1);
sound(gain*y,Fs);

figure;
subplot(1,2,1); spectrogram(x,1024,768,1024,Fs,'yaxis'); title('Original');
subplot(1,2,2); spectrogram(y,1024,768,1024,Fs,'yaxis'); title('Filtered');