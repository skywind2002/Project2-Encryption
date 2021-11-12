% 利用时域信号波形的采样值 f 和采样间隔 Ts 计算其功率谱
% 功率谱定义为时域波形的傅里叶变换的模方，这里利用 DTFT 和 fourier 的关系计算 DTFT 以获得 fourier
% 计算 DTFT 时通过 FFT 算法进行，实际做的是 DFT
% x - 时域信号波形的采样值
% Ts - 采样间隔
% N - 功率谱采样点数量
% P - 功率谱的采样点
% f - 功率谱的采样点对应的频率
function [P, f] = power_spectrum(x, Ts, N)
    Fs = 1 / Ts;
    f = linspace(-Fs/2, Fs/2 - Fs/N, N);
    X = Ts * fftshift(fft(x, N));
    P = abs(X).^2;
end
    