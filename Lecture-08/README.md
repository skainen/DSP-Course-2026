# Edge detector comparison on clean and noisy images

## Files

| File | Content |
|---|---|
| `edge_compare.m` | Live Script: runs the whole comparison and writes `results/` |
| `results/edge_maps_overview.png` | All six edge maps in one figure, with `nnz` in each title |
| `results/zoom_sky_tripod.png` | Close-ups: sky (no true edges) and tripod (thin structure) |
| `results/edge_counts.csv` | Edge-pixel count per detector, clean and noisy, plus the noisy/clean ratio |
| `results/edge_agreement.csv` | Noisy map vs clean map per detector: kept, lost, invented, edge pixels in the sky |
| `results/{sobel_g1,canny_s1,canny_s3}_{clean,noisy}.png` | The six binary edge maps at full resolution |
| `results/cameraman_noisy.png` | The noisy input image |
| `results/matlab_version.txt` | MATLAB version used for the run |

**Input image:** `cameraman.tif` (256×256, uint8; ships with the Image Processing Toolbox).

## Settings

| Item | Setting |
|---|---|
| Noise | `rng(42); In = imnoise(I, 'gaussian', 0, 0.01);` (mean 0, variance 0.01) |
| Sobel | `edge(imgaussfilt(I, 1), 'sobel')`, default threshold |
| Canny σ=1 | `edge(I, 'canny', [], 1)`, default thresholds |
| Canny σ=3 | `edge(I, 'canny', [], 3)`, default thresholds |
| Agreement tolerance | 1 px (`strel('disk', 1)`) |
| Sky region | rows 1–90, columns 150–256 |

**MATLAB version:** TODO (copy from `results/matlab_version.txt`). Requires the Image Processing Toolbox.

## How to run

1. Put `edge_compare.m` in a folder and make that folder the current folder in MATLAB.
2. Open the Live Script and click **Run** on the Live Editor tab, or type `edge_compare` in the Command Window.
3. The script creates `results/` and writes all figures, tables and edge maps there. It runs in a few seconds and needs no other files.

The noise comes from `rng(42)`, so repeated runs on the same MATLAB version give the same numbers.

## Results

From `results/edge_counts.csv`:

| | Sobel (σ=1 pre-smoothing) | Canny σ=1 | Canny σ=3 |
|---|---|---|---|
| clean | TODO | TODO | TODO |
| noisy | TODO | TODO | TODO |

## Main conclusion

With default thresholds, the amount of smoothing decides how many false edges the noise produces.

- **Canny σ=1** turns the noise into many false edges. The count roughly doubles on the noisy image, and the sky, which contains no true edges, fills with short curved strands. MATLAB sets the default high threshold so that 70% of pixels count as non-edge, so about 30% of gradient magnitudes are always candidates, whatever the image contains.
- **Canny σ=3** suppresses almost all of the noise. Its count barely changes. The cost is lost detail even on the clean image: the low-contrast buildings on the right of the horizon disappear, corners are rounded, and the two sides of each thin tripod leg merge.
- **Sobel with σ=1 pre-smoothing** is the most stable of the three. Its default threshold scales with the mean gradient energy, so noise raises the threshold. The count drops slightly on the noisy image: weak true edges are removed rather than false ones added.

Edge detection on noisy images trades noise suppression (larger σ) against localisation and fine detail (smaller σ).

## Limitation

The edge-pixel count (`nnz`) does not measure correctness. A count can stay the same while true edges are lost and false ones invented, because the two cancel out. A count can also fall while the map gets worse. Measuring correctness needs a reference edge map and a matched comparison, such as precision and recall with a distance tolerance. `edge_agreement.csv` approximates this using the clean-image map as the reference, but that reference is itself detector-dependent: Canny σ=1 already marks grass texture as edges on the clean image.

## AI Use

Claude Opus 5.5 used for code generation and explanation.
