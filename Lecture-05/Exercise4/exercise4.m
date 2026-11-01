x = [1 1 1 1];
n = 0:length(x)-1;

w = linspace(-pi, pi, 1000);
X = x * exp(-1j * (n.' * w));

figure
plot(w, abs(X))
grid on
xlabel('Angular frequency (rad/sample)')
ylabel('Magnitude')
title('DTFT of x = [1 1 1 1]')
saveas(gcf, 'exercise4_dtft.png')

Ns = [4 64];
figure
for i = 1:2
    N = Ns(i);
    Xk = fftshift(fft(x, N));          % reorder bins to -pi ... pi
    wk = 2*pi*(-N/2:N/2-1)/N;          % bin frequencies in rad/sample

    subplot(2, 1, i)
    plot(w, abs(X), '--')              % DTFT for reference
    hold on
    stem(wk, abs(Xk), 'filled')
    hold off
    grid on
    xlim([-pi pi])
    xlabel('Angular frequency (rad/sample)')
    ylabel('Magnitude')
    title(sprintf('fft(x, %d) vs DTFT', N))
end
saveas(gcf, 'exercise4_dft_vs_dtft.png')