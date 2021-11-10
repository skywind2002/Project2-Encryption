% 尝试将比特调制的冲激序列过低通与sinc函数比较

clear;close all;clc;

Ts = 1; % 采样间隔 (s)

%% prefourier
precision = 0.001;
t_start = 0;
t_end = 10;
t_range = [t_start, t_end];
t_N = (t_end - t_start) / precision;
omega_range = [-10, 10];
omega_N = 4000;
[t, omg, FT, IFT] = prefourier(t_range, t_N, omega_range, omega_N);
t = t';

%% 发送
a_k = [0, 1, 1, 0, 1, 0, 1]; % 要发送的比特序列

%% 调制

% 【非归零码】
s_t1 = zeros(1, length(t));

for n = 1:length(a_k)
    % s_t1 = (heaviside(t - n * Ts + Ts / 2) - heaviside(t - (n + 1) * Ts + Ts / 2)) .* a_k(n) + s_t1;
    s_t1(n * Ts / precision) = a_k(n) * 1000; % 这里乘系数1000表示delta函数
    % s_t1 = a_k(n) * dirac(t - n * Ts) + s_t1;
end

% 时域
figure(1); subplot(3, 1, 1);
plot(t, s_t1); xlabel("t"); legend("非归零码");
% 频域
figure(2); subplot(3, 1, 1);
plot(omg, abs(FT * s_t1')); xlabel("\omega"); legend("F(s(t1))")

% 【非归零码过低通】
w_c = pi; % 下面直接用了sinc `syms x;fourier(sinc(x))` -> `(pi*heaviside(pi - w) - pi*heaviside(- w - pi))/pi`
s_t2 = IFT * (FT * s_t1' .* (omg > -w_c & omg < w_c));

figure(1); subplot(3, 1, 2);
plot(t, real(s_t2)); xlabel("t"); legend("非归零码过低通"); % 这里imag部分比较小 毕竟是实信号的频谱做ift 加上real不警告
figure(2); subplot(3, 1, 2);
plot(omg, abs(FT * s_t1' .* (omg > -w_c & omg < w_c))); xlabel("\omega"); legend("F(s(t2))")

% 【直接用sinc函数加权】
s_t3 = zeros(1, length(t)); % 发送的波形：由比特序列调制得到

for n = 1:length(a_k)
    s_t3 = s_t3 + a_k(n) * sinc(t - n * Ts);
end

figure(1); subplot(3, 1, 3);
plot(t, s_t3); xlabel("t"); legend("直接用sinc函数加权得到的连续波形");
figure(2); subplot(3, 1, 3);
plot(omg, abs(FT * s_t3')); xlabel("\omega"); legend("F(s(t3))")

% % [信道]
% r_t = s_t3; % r_t 经过信道后的波形
% subplot(3, 1, 2)
% plot(t, r_t); xlabel("t"); legend("r(t)");

% % [接收]
% y_t = r_t; % y_t 经过接收机后的波形
% subplot(3, 1, 3)
% plot(t, y_t); xlabel("t"); legend("y(t)");

% % 采样/判决
% y_n = zeros(1, length(a_k)); % y_n 采样得到的比特序列

% for n = 1:length(a_k)
%     y_n(n) = y_t(n * Ts / precision);
% end

% fprintf("y_n"); disp(y_n);
