# Lecture 6 - Digital Filtering Assignment

### 1.  Why is a 20 Hz low-pass reasonable for Part A, and what assumption does it make about the wanted sensor signal?

The wanted signals are at 5 Hz and 12 Hz,
and the interference starts at 50 Hz. 20 Hz
sits in-between, and it can be assumed that nothing above 20 Hz matters.

### 2. Which filter gives the better result for the requirements you chose? Support the answer with at least two kinds of evidence.

For offline filtering with accurate amplitude as requirement, the IIR wins.
The IIR halves the FIR's error.
At 12 Hz, the IIR also keeps 0.34 of the 0.35 amplitude, while
FIR keeps only 0.23. Both filters suppress the 50 Hz and above tones well,
so the meaningful difference comes from the passband which is up to 20 Hz.

### 3. How would your implementation change if the sensor had to be filtered live with low latency?

Here we used filtfilt. filtfilt's backward pass needs future samples, so it cannot run live.
A live version could use a causal single pass (a filter with persistent state)
processing sample by sample or in small blocks.


### 4. Why is a narrow band-stop appropriate for a steady 50 Hz hum? What would you do if the interference frequency drifted?

A steady hum is a clear single spectral line at fairly low amplitude. A narrow notch removes the hum while leaving
most of the useful audio untouched.

If the interference frequency drifted, an adaptive notch filter could be implemented.
The adaptive notch filter's centre frequency is tracked continuously.

### 5.  Describe one limitation of your experiments and one improvement you would make in a real measurement system.

These examples were ideal for testing. In reality the signals will in many cases be non-stationary.
In a real measurement system I would specify the requirements, then design the filters to meet them.
Then the filters need to be validated on recorded sensor data.
