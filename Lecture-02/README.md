### Sampling and Aliasing Investigation using MATLAB

## Nyquist Analysis

The original signal has a frequency of f_max = 10 Hz.
The minimum sampling frequency using the Nyquist Sampling Theorem is:
f_s > 2*f_max = 2 * 10 Hz = 20 Hz

The sampling frequencies that satisfy the Nyquist criterion are 25, 50 and 100 Hz. 15 Hz doesn't satisfy it, and 20 Hz is exactly at the limit, so it doesn't meet the criterion either.

Sampling exactly at the Nyquist rate is not recommended. Often a safety margin of for example 2.5 times the highest frequency or higher is used.
At the exact Nyquist rate 2*f, there is no room for error. The result depends on the phase of the signal. In our 20 Hz case all samples hit zeros, but a cosine would give ±1, so the amplitude cannot be recovered.
It also assumes an ideal "brick-wall" anti-aliasing filter that cuts off unwanted frequencies, which is a filter that in reality cannot exist.
Real-world filters also have a gradual transition band. Sampling too close to the edge or below the Nyquist rate lets high frequencies bleed back into the signal as distorted low-frequency noise, which is called aliasing.

## Aliasing

In our example, aliasing occurs at 15 Hz, where the 10 Hz signal shows up as |10 - 15| = 5 Hz. At 20 Hz the frequency is exactly the Nyquist limit and all samples hit zeros. At 25, 50 and 100 Hz aliasing doesn't occur.
Aliasing happens because sampling replicates the signal spectrum at integer multiples of sampling frequency f_s. When f_s < 2f, they overlap the baseband. Then the 10 Hz signal produces exactly the same sample sequence as a 5 Hz signal and they look the same. They cannot be told apart.

## Engineering Recommendation
Here a 100 Hz sampling frequency is recommended. Ten samples per period capture the waveform shape accurately. The large margin between 10 Hz and the 50 Hz Nyquist frequency allows a simple anti-aliasing filter and handles noise and small frequency changes better. 100 samples per second is also very light for any modern microcontroller to process. If the system was memory constrained, a lower rate like 50 Hz would be acceptable as well.

## AI Usage
Claude Opus 5.5 was used. I prompted the original matlab code from lecture material to fit better for the task. Claude gave a fitting code, and I modified the values.
I wrote a README.md, then prompted it to Claude, which corrected my sentencing. I confused sampling frequency and signal frequency.
