%% Lecture 8 exercises

clear; close all; clc;

I = imread('cameraman.tif');   % reference image for sections 1, 2, 4, 5

%% 1. Image = matrix
disp(size(I)), disp(class(I))          % 256x256 uint8
I(100,120)
figure, imshow(I(100:107,120:127), 'InitialMagnification', 'fit'), title('8x8 patch')

P = imread('peppers.png');  R = P(:,:,1);  G = rgb2gray(P);
figure, montage({P, cat(3,R,R,R), cat(3,G,G,G)}), title('RGB | red channel | gray')

% Quantization
b = [8 4 2 1];
figure
for k = 1:4
    step = 256 / 2^b(k);
    Q = uint8(floor(double(I)/step)*step);
    subplot(1,4,k), imshow(Q), title(sprintf('%d bit', b(k)))
end

% Aliasing: plain decimation vs low-pass + decimation
A1 = I(1:8:end, 1:8:end);
A2 = imresize(I, 1/8);                  % antialiasing on by default when shrinking
figure
subplot(1,2,1), imshow(A1, 'InitialMagnification', 800), title('decimate only')
subplot(1,2,2), imshow(A2, 'InitialMagnification', 800), title('imresize (low-pass)')

%% 2. Degradations
Ig  = imnoise(I, 'gaussian', 0, 0.01);
Isp = imnoise(I, 'salt & pepper', 0.05);
Ib  = imfilter(I, fspecial('motion', 15, 30), 'replicate', 'conv');   % true convolution
[~, Y] = meshgrid(1:size(I,2), 1:size(I,1));
Il  = uint8(double(I) .* (0.4 + 0.6*Y/size(I,1)));                   % multiplicative ramp
figure, montage({Ig, Isp, Ib, Il}, 'Size', [1 4])
title('gaussian | salt & pepper | motion blur | uneven lighting')

%% 3. Contrast and geometry
Pt = imread('pout.tif');
figure, imhist(Pt), title('pout.tif histogram')
J = imadjust(Pt, stretchlim(Pt), []);
B = imadjust(Pt, [], [], 0.5);           % gamma < 1 brightens
D = imadjust(Pt, [], [], 2);             % gamma > 1 darkens
K = histeq(Pt);
figure, montage({Pt, J, B, D, K}, 'Size', [1 5])
title('original | stretch | gamma 0.5 | gamma 2 | histeq')

Cp = imcrop(I, [60 40 39 39]);          % imcrop is inclusive: width 39 -> 40 px
assert(isequal(size(Cp), [40 40]))
figure
subplot(1,3,1), imshow(imresize(Cp, 4, 'nearest')),  title('nearest')
subplot(1,3,2), imshow(imresize(Cp, 4, 'bicubic')),  title('bicubic')
subplot(1,3,3), imshow(imrotate(Cp, 30, 'bilinear', 'crop')), title('rotate 30, bilinear')

%% 4. Filtering and denoising
% One pixel by hand. imfilter correlates; for a symmetric kernel that equals convolution.
f = double(I(100:102,120:122));
byHand = sum(f(:) .* reshape(ones(3)/9, [], 1));
g = imfilter(I, ones(3)/9, 'replicate');
fprintf('By hand: %.2f   imfilter: %d\n', byHand, g(101,121));

% Every filter on every noisy image: 3 x 2 = 6 results
noisy   = {Ig, Isp};
noiseNm = {'Gaussian', 'SaltPepper'};
filtNm  = {'Mean3x3', 'Gauss_s1_5', 'Median3x3'};
filt    = {@(x) imfilter(x, ones(3)/9, 'replicate'), ...
           @(x) imgaussfilt(x, 1.5), ...
           @(x) medfilt2(x, [3 3])};
PSNR = zeros(3,2);
figure, t = tiledlayout(2,3, 'TileSpacing', 'compact');
for n = 1:2
    for m = 1:3
        out = filt{m}(noisy{n});
        PSNR(m,n) = psnr(out, I);        % against the cameraman original
        nexttile, imshow(out), title(sprintf('%s on %s: %.1f dB', filtNm{m}, noiseNm{n}, PSNR(m,n)), 'Interpreter', 'none')
    end
end
fprintf('Noisy input PSNR: Gaussian %.1f dB, S&P %.1f dB\n', psnr(Ig, I), psnr(Isp, I));
disp(array2table(PSNR, 'RowNames', filtNm, 'VariableNames', noiseNm))

% Spectrum: original vs Gaussian blur vs motion blur
spec = @(x) log(1 + abs(fftshift(fft2(double(x)))));
figure
subplot(1,3,1), imshow(spec(I), []), title('original')
subplot(1,3,2), imshow(spec(imgaussfilt(I, 3)), []), title('gaussian \sigma=3')
subplot(1,3,3), imshow(spec(Ib), []), title('motion blur')

%% 5. Edge detection
Cs = imgaussfilt(I, 1);
[Gmag, Gdir] = imgradient(Cs, 'sobel');
E1 = edge(Cs, 'sobel');
E2 = edge(Cs, 'canny');
figure, montage({mat2gray(Gmag), E1, E2}, 'Size', [1 3]), title('|grad| | Sobel | Canny')

% Canny sigma sweep
sig = [1 2 3];
figure
for k = 1:3
    E = edge(I, 'canny', [], sig(k));
    subplot(1,3,k), imshow(E), title(sprintf('\\sigma = %d, %d px', sig(k), nnz(E)))
end

% Noisy image with and without extra smoothing
En  = edge(Ig, 'canny');
Ens = edge(imgaussfilt(Ig, 2), 'canny');
fprintf('Canny on noisy image: %d edge px raw, %d smoothed\n', nnz(En), nnz(Ens));
figure, montage({En, Ens}), title('noisy: raw | pre-smoothed')

%% 6. Thresholding, morphology, segmentation
Co  = imread('coins.png');
BW0 = imbinarize(Co, graythresh(Co));                % Otsu
BW1 = imopen(BW0, strel('disk', 5));                 % remove specks
BW2 = imfill(BW1, 'holes');                          % fill coin interiors
BW3 = bwareaopen(BW2, 100);                          % drop anything < 100 px
figure, montage({BW0, BW1, BW2, BW3}, 'Size', [1 4]), title('Otsu | open | fill | areaopen')

[L, n] = bwlabel(BW3);
s = regionprops(BW3, 'Area', 'Centroid', 'Eccentricity');
areas = [s.Area];
fprintf('%d coins, mean area %.1f px, std %.1f px\n', n, mean(areas), std(areas));
for k = 1:n
    fprintf('  coin %2d: area %5d px, ecc %.2f\n', k, s(k).Area, s(k).Eccentricity);
end
[~, big] = max(areas);
figure, imshow(label2rgb(L, 'jet', 'k', 'shuffle')), hold on
c = cat(1, s.Centroid);
text(c(:,1), c(:,2), string(1:n), 'Color', 'w', 'FontWeight', 'bold', 'HorizontalAlignment', 'center')
plot(c(big,1), c(big,2), 'wo', 'MarkerSize', 30, 'LineWidth', 2), hold off
title(sprintf('largest: coin %d', big))

Ri  = imread('rice.png');
BWg = imbinarize(Ri);                                % global: fails at the bottom
BWa = imbinarize(Ri, adaptthresh(Ri, 0.5));          % adaptive
figure, montage({Ri, BWg, BWa}, 'Size', [1 3]), title('rice | global Otsu | adaptive')

%% 7. Pipeline: denoise -> flatten lighting -> threshold -> clean -> measure
Id   = imnoise(imnoise(Ri, 'gaussian', 0, 0.01), 'salt & pepper', 0.02);
Iden = imgaussfilt(medfilt2(Id, [3 3]), 1);          % median first (outliers), then gaussian
bg   = imopen(Iden, strel('disk', 15));              % disk larger than any grain
Ic   = imadjust(Iden - bg);                          % top-hat + stretch
BWr  = bwareaopen(imbinarize(Ic), 50);
sr   = regionprops(BWr, 'Area');
fprintf('Grains: %d, mean area: %.1f px\n', numel(sr), mean([sr.Area]));
figure, montage({Id, Iden, bg, Ic, BWr}, 'Size', [1 5])
title('noisy | denoised | background | corrected | mask')
