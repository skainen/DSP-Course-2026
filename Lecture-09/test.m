%% Lab 6: Mini Project – Night city: sharpen + recolor lights
close all; clear; clc;

%% 1) Load (colour), robust to indexed / grayscale PNGs
[X, map] = imread('city1.png');
if ~isempty(map)
    RGB = ind2rgb(X, map);                % palette PNG -> true colour (already double)
else
    RGB = im2double(X);
    if size(RGB,3) == 1, RGB = repmat(RGB, 1, 1, 3); end   % grayscale -> 3 channels
end
[M,N,~] = size(RGB);

%% 2) Denoise lightness only (night shots are noisy; sharpening would amplify it)
lab = rgb2lab(RGB);
L = lab(:,:,1) / 100;                     % [0,1]
L = medfilt2(L, [3 3], 'symmetric');

%% 3) Sharpen: frequency-domain high-boost (unsharp mask)
%    H_hb = 1 + k*(1 - H_LP)  -> passes lows unchanged, boosts highs by (1+k)
[u,v] = meshgrid(-floor(N/2):ceil(N/2)-1, -floor(M/2):ceil(M/2)-1);
D = sqrt(u.^2 + v.^2);
sigma = 40;  k = 1.5;                     % tune: smaller sigma = coarser detail boosted
H_hb = 1 + k*(1 - exp(-D.^2/(2*sigma^2)));
Lp = padarray(L, [M N], 'symmetric', 'post');   % pad to avoid wrap-around at borders
Fp = fftshift(fft2(Lp));
[Mp,Np] = size(Lp);
[up,vp] = meshgrid(-floor(Np/2):ceil(Np/2)-1, -floor(Mp/2):ceil(Mp/2)-1);
Dp = sqrt((up*N/Np).^2 + (vp*M/Mp).^2);   % same physical cutoff on padded grid
H_hb = 1 + k*(1 - exp(-Dp.^2/(2*sigma^2)));
L_sh = real(ifft2(ifftshift(Fp .* H_hb)));
L_sh = min(max(L_sh(1:M,1:N), 0), 1);

lab_sh = lab;  lab_sh(:,:,1) = 100*L_sh;
RGB_sh = min(max(lab2rgb(lab_sh), 0), 1);

%% 4) Recolor the lights
hsv = rgb2hsv(RGB);                       % detect on the un-sharpened image (no halos)
V = hsv(:,:,3);  S = hsv(:,:,2);
H = hsv(:,:,1);
mask = V > 0.6 & S > 0.3 & H > 0.03 & H < 0.14;   % orange-ish only
mask = bwareaopen(mask, 4);               % drop single-pixel speckle
m = imgaussfilt(double(mask), 2);         % soft edge -> natural glow transition

target_hue = 0.55;                        % 0 red, 0.08 orange, 0.33 green, 0.55 cyan, 0.75 purple
hsv_sh = rgb2hsv(RGB_sh);
hsv_rc = hsv_sh;
hsv_rc(:,:,1) = target_hue;
hsv_rc(:,:,2) = max(hsv_sh(:,:,2), 0.7);  % white-clipped cores need saturation to show colour
RGB_rc = hsv2rgb(hsv_rc);

RGB_out = (1 - m).*RGB_sh + m.*RGB_rc;    % blend in RGB (avoids hue wrap-around artefacts)

%% 5) Features: edges on the enhanced lightness
edges = edge(L_sh, 'Canny', [0.1 0.25]);

%% 6) Visualization
figure; montage({RGB, RGB_sh, RGB_out}, 'Size', [1 3]);
title('Original | Sharpened (high-boost) | Recolored lights');
figure; montage({mask, m, edges}, 'Size', [1 3]);
title('Light mask | Soft mask | Canny edges');
figure; imshow(log(1+abs(H_hb)), []); title('High-boost filter |H| (log)');