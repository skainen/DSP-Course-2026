# Lecture 03 - Signal Operations and Convolution

## Questions

### 1. Which operation changed the signal amplitude?

The measured signal's amplitude was scaled by 2 in Task 1.

### 2. How did the five-sample delay change the signal?

It shifted the signal 5 samples to the right, toward larger n.
delayed[n] = measured[n - 5].

### 3. What does the impulse response h[n] represent?

It's the output of the system when the input is a single impulse.
For LTI system h[n] completely describes the system:
any input can be written as a sum of shifted, scaled impulses, so the output is the sum of shifted, scaled copies of h[n], which is convolution, y[n] = x[n] * h[n].
For moving-average filter, h[n] = 1/N for N consecutive samples, meaning each output sample is the equal-weight average of N neighbouring input samples.

### 4. How did convolution change the noisy signal?

It replaced each sample with the average of itself and its four neighbours. In noise_filtering.png the filtered curve follows the clean sine closely and the sharp sample-to-sample spikes of the noisy signal are gone.

### 5. What differences did you observe between the 5-point and 15-point filters?

The 15-point filter is much smoother, but its peaks are only +- 0.35 of the clean signals 1. 5-point filter kept the amplitude much closer to the clean signal, but in turn carries a bit more noise.

### 6. Which filter removed more noise?

15-point filter removed more noise.

### 7. Did the longer filter remove or distort useful signal information?

It distorted the signal.
The filter's gain at ω = 0.1π is:

|H(e^{jω})| = (1/N) · |sin(Nω/2) / sin(ω/2)|

which gives about 0.90 for N = 5 but only about 0.30 for N = 15. The 15-point output therefore keeps only about 30 % of the original amplitude, which matches the ±0.35 peaks in filter_comparison.png.

### 8. Which filter would you recommend for this signal? Explain your decision.

I'll recommend the 5-point filter since it removes some of the noise while still being very close to the clean signal in amplitude. 15-point filter removes about 70% of the signal, so it no longer represents the original signal.

### 9. Give one real engineering application for moving-average filtering.

A microcontroller reading a noisy analog sensor, such as a distance sensor, can keep the last n samples in a ring buffer and output their average. The filter smoothes the sensor's readings.


## AI usage

Tool used: Claude Opus 5.5.

How I used it: Code check, explanation.
