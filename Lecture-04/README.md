1. The power of z^-1 is the sample index and the coefficient is the amplitude


2. x[n−1] = {0, 1, 2, 1}, starting at n = 0:
X(z) = z^-1 + 2z^-2 + z^-3

3. A one sample delay moves every sample one index later so every exponent goes up by one.
Multiplying each term by z^-1 raises its exponent by one.


4. Y(z) = H(z)X(z) = 0.5(1+z^-1)(1+2z^-1+z^-2) = 0.5 + 1.5z^-1 + 1.5z^-2 + 0.5z^-3

5. b(1) = 0.5 multiplies z^0, the current input. b(2) = 0.5 multiplies z^-1, the previous input.
Setting a = 1 means the denominator is 1.


6. The current input x[n] has four times the weight of the previous one. Output follows the input much more closely with the peak at n = 1 and much less smoothing.
