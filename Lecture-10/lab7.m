%% Lab 7: Traditional vs AI denoising - quality and runtime comparison
close all; clear; clc;
rng(0);                                   % reproducible noise -> same numbers every run

%% 1) Setup: load image and add Gaussian noise
originalImage = im2double(imread('cameraman.tif'));
noiseSigma = 0.04;                        % ~10 in 8-bit units
noisyImage = imnoise(originalImage, 'gaussian', 0, noiseSigma^2);
[M, N] = size(originalImage);

%% 2) Methods under test: {name, function handle}
methods = {
    'Gaussian blur (s=1)',   @(J) imgaussfilt(J, 1)
    'Median 3x3',            @(J) medfilt2(J, [3 3], 'symmetric')
    'Wiener 5x5 (oracle)',   @(J) wiener2(J, [5 5], noiseSigma^2)   % given true noise variance
    'Wiener 5x5 (blind)',    @(J) wiener2(J, [5 5])                 % estimates noise itself
    'Non-Local Means',       @(J) imnlmfilt(J, 'DegreeOfSmoothing', noiseSigma)
};

% AI method (needs Deep Learning Toolbox)
hasDL = ~isempty(ver('nnet'));
tLoadNet = NaN;
if hasDL
    tLoad = tic;
    net = denoisingNetwork('DnCNN');
    tLoadNet = toc(tLoad);                % one-time model load cost, reported separately
    methods(end+1, :) = {'DnCNN (AI)', @(J) denoiseImage(J, net)};
else
    warning('Deep Learning Toolbox not found - DnCNN skipped.');
end

%% 3) Run, time and score each method
K = size(methods, 1);
outs = cell(K, 1);
P = zeros(K, 1);  S = zeros(K, 1);  T = zeros(K, 1);  Tfirst = zeros(K, 1);

for k = 1:K
    f = methods{k, 2};
    t0 = tic;
    outs{k} = f(noisyImage);              % first (cold) call: includes JIT / init overhead
    Tfirst(k) = toc(t0);
    T(k) = timeit(@() f(noisyImage));     % warm runtime: median over repeated runs
    P(k) = psnr(outs{k}, originalImage);
    S(k) = ssim(outs{k}, originalImage);
end

psnrNoisy = psnr(noisyImage, originalImage);
ssimNoisy = ssim(noisyImage, originalImage);

%% 4) Results table
names = [{'Noisy (no filter)'}; methods(:, 1)];
R = table(names, [psnrNoisy; P], [ssimNoisy; S], [NaN; 1000*T], [NaN; 1000*Tfirst], ...
    'VariableNames', {'Method', 'PSNR_dB', 'SSIM', 'Time_ms', 'FirstCall_ms'});
R.Gain_dB   = R.PSNR_dB - psnrNoisy;                       % improvement over noisy input
R.Mpx_per_s = (M*N/1e6) ./ (R.Time_ms/1000);               % throughput, size-independent
R.RelTime   = R.Time_ms / min(R.Time_ms);                  % x slower than fastest method

% Environment (timings are meaningless without it)
if exist('canUseGPU', 'file') && canUseGPU
    g = gpuDevice;  gpuStr = g.Name;
else
    gpuStr = 'none (CPU only)';
end
fprintf('\nMATLAB %s | %s | threads: %d | GPU: %s\n', ...
    version, computer, maxNumCompThreads, gpuStr);
fprintf('Image: %dx%d, noise sigma = %.3f (%.1f in 8-bit units)\n', M, N, noiseSigma, 255*noiseSigma);
if hasDL, fprintf('DnCNN model load time: %.0f ms (one-time)\n', 1000*tLoadNet); end

fprintf('\n%-22s | %9s | %7s | %8s | %10s | %10s | %9s | %7s\n', ...
    'Method', 'PSNR (dB)', 'Gain', 'SSIM', 'Time (ms)', '1st call', 'Mpx/s', 'xSlower');
fprintf('%s\n', repmat('-', 1, 103));
for i = 1:height(R)
    fprintf('%-22s | %9.2f | %+7.2f | %8.4f | %10.2f | %10.2f | %9.2f | %7.1f\n', ...
        R.Method{i}, R.PSNR_dB(i), R.Gain_dB(i), R.SSIM(i), ...
        R.Time_ms(i), R.FirstCall_ms(i), R.Mpx_per_s(i), R.RelTime(i));
end
writetable(R, 'lab7_results.csv');        % for the report / README table
fprintf('\nSaved: lab7_results.csv\n');

%% 5) Figures
% 5a) Outputs
figure('Name', 'Denoising outputs');
tiledlayout('flow', 'TileSpacing', 'compact');
nexttile; imshow(originalImage); title('Original');
nexttile; imshow(noisyImage); title(sprintf('Noisy  %.2f dB', psnrNoisy));
for k = 1:K
    nexttile; imshow(outs{k});
    title(sprintf('%s\n%.2f dB | %.3f | %.1f ms', methods{k,1}, P(k), S(k), 1000*T(k)), ...
        'FontSize', 8);
end

% 5b) Residuals: what each method removed. Pure noise = good; visible edges = lost detail
figure('Name', 'Residuals (noisy - denoised)');
tiledlayout('flow', 'TileSpacing', 'compact');
for k = 1:K
    nexttile; imshow(noisyImage - outs{k}, [-0.15 0.15]);
    title(methods{k,1}, 'FontSize', 8);
end

% 5c) Zoomed crops (adjust region to a textured area)
rows = 30:130;  cols = 60:160;
figure('Name', 'Zoomed detail');
tiledlayout('flow', 'TileSpacing', 'compact');
nexttile; imshow(originalImage(rows, cols)); title('Original');
nexttile; imshow(noisyImage(rows, cols)); title('Noisy');
for k = 1:K
    nexttile; imshow(outs{k}(rows, cols)); title(methods{k,1}, 'FontSize', 8);
end

% 5d) Quality vs speed trade-off
figure('Name', 'Quality vs runtime');
semilogx(1000*T, P, 'o', 'MarkerSize', 8, 'LineWidth', 1.5); hold on; grid on;
text(1000*T, P, "  " + string(methods(:,1)), 'FontSize', 8);
yline(psnrNoisy, '--', 'Noisy input');
xlabel('Runtime per image (ms, log scale)'); ylabel('PSNR (dB)');
title('Denoising: quality vs runtime');

%% 6) Observations (fill in from YOUR measured results)
% - Which method gave the highest PSNR/SSIM, and by how much over Wiener?
% - Runtime ratio DnCNN vs Wiener, and whether it ran on CPU or GPU.
% - Oracle vs blind Wiener: how much does knowing the noise variance help?
% - Residual maps: which methods remove structure (edges visible) vs only noise?