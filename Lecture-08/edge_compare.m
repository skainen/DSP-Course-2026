%% Edge detector comparison: clean vs noisy cameraman
clear; close all; clc;

I = imread('cameraman.tif');
rng(42);
In = imnoise(I, 'gaussian', 0, 0.01);

imgs    = {I, In};
imgName = {'clean', 'noisy'};
detName = {'Sobel (gauss \sigma=1)', 'Canny \sigma=1', 'Canny \sigma=3'};
det     = {@(x) edge(imgaussfilt(x, 1), 'sobel'), ...   % default threshold
           @(x) edge(x, 'canny', [], 1), ...            % [] = default thresholds
           @(x) edge(x, 'canny', [], 3)};

E = cell(2, 3);
N = zeros(2, 3);
for r = 1:2
    for c = 1:3
        E{r,c} = det{c}(imgs{r});
        N(r,c) = nnz(E{r,c});
    end
end

% All six maps in one figure
figure('Position', [100 100 1200 800]);
tl = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for r = 1:2
    for c = 1:3
        nexttile
        imshow(E{r,c})
        title(sprintf('%s, %s: %d px', detName{c}, imgName{r}, N(r,c)))
    end
end
title(tl, 'Edge maps (default thresholds)')

% nnz table
T = array2table(N, 'RowNames', imgName, ...
    'VariableNames', {'Sobel_g1', 'Canny_s1', 'Canny_s3'});
T{'noisy/clean', :} = N(2,:) ./ N(1,:);
disp(T)

% Agreement with the clean map, to make the "count is not correctness" point concrete.
% Dilate the clean map by 1 px so small shifts still count as matches.
fprintf('\n%-12s %10s %10s %10s\n', 'detector', 'kept', 'lost', 'invented');
se = strel('disk', 1);
for c = 1:3
    ref   = E{1,c};
    test  = E{2,c};
    kept  = nnz(test & imdilate(ref, se));
    inv   = nnz(test & ~imdilate(ref, se));        % noisy edge with no clean edge nearby
    lost  = nnz(ref & ~imdilate(test, se));        % clean edge with no noisy edge nearby
    fprintf('%-12s %10d %10d %10d\n', T.Properties.VariableNames{c}, kept, lost, inv);
end

% Zoom: sky (no true edges) and the tripod/legs (thin structure)
figure('Position', [100 100 1200 500]);
tiledlayout(2, 4, 'TileSpacing', 'compact');
sky = {1:90, 150:256};  legs = {170:256, 60:200};
for c = [2 3]
    nexttile, imshow(E{1,c}(sky{:})),  title(sprintf('sky, clean, %s', detName{c}))
    nexttile, imshow(E{2,c}(sky{:})),  title(sprintf('sky, noisy, %s', detName{c}))
    nexttile, imshow(E{1,c}(legs{:})), title(sprintf('tripod, clean, %s', detName{c}))
    nexttile, imshow(E{2,c}(legs{:})), title(sprintf('tripod, noisy, %s', detName{c}))
end