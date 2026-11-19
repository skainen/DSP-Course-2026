# Analysing an environmental sound

## Audio

`classification/1-17150-A-12.wav` (crackling_fire, 5 s), from the supplied course package. The clip comes from the ESC-50 dataset (K. J. Piczak, 2015, CC BY-NC 3.0, original recordings from Freesound.org). The audio is not included in this repository.

## Settings

16 kHz mono. Spectrograms with Hann windows of 512 and 2048 samples, hop 160 samples, shown 0–8 kHz.

## Main conclusion

In the 512 sample, 32 ms window spectrogram, the shorter window localises crackles within a few frames and keeps them separated. The 128 ms window spreads every impulse over 128 ms, and the events merge together, showing as a more hazy version of the other spectrogram.

## Limitation

The analysis uses audio resampled to 16 kHz, so nothing above 8 kHz is visible. The spectrum is still near its maximum level at 7-7.5 kHz before the anti-alias roll-off at 7.6 kHz, which indicates that some of the crackle energy is above the analysed band.