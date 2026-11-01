t = linspace(-1, 1, 4000);
Hs = [1 3 9 25];

figure
hold on
for H = Hs
    x = zeros(size(t));
    for k = 1:2:H
        x = x + (4/pi) * sin(2*pi*k*t) / k;
    end
    plot(t, x, 'DisplayName', sprintf('H = %d', H))
end
hold off
grid on
legend
xlabel('Time (s)')
ylabel('Amplitude')
title('Square wave approximation')
saveas(gcf, 'exercise1.png')