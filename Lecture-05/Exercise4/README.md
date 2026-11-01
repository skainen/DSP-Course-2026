## Exercise 4

Task 4. The DFT values lie on the DTFT curve, because the DFT is the DTFT sampled at N evenly spaced frequencies. With N = 4, the samples land on the peak and on the zeros, so the result is just [4 0 0 0]. With N = 64, the samples are dense enough to show the shape of the curve.

Task 5. fft(x,64) adds 60 zeros to the end of x, so it returns 64 frequency points instead of 4. This doesn’t add any new samples to the original sequence. It only samples the same DTFT more densely.

Task 6. The magnitude is zero at omega = +-pi/2 and +-pi rad/sample.