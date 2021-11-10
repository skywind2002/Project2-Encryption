clear;close all;clc;

Ts = 1; % 采样间隔 (s)
precision = 0.01;
t_start = 0;
t_end = 10;
t = (t_start + precision):(precision):(t_end);

% [发端]
a_k = [0, 1, 1, 0, 1, 0, 1]; % 要发送的比特序列

% 调制
s_t = zeros(1, length(t)); % 发送的波形：由比特序列调制得到

for n = 1:length(a_k)
    s_t = a_k(n) * sinc(t - n * Ts) + s_t;
end

subplot(3, 1, 1)
plot(t, s_t); xlabel("t"); legend("s(t)");

% [信道]
r_t = s_t; % r_t 经过信道后的波形
subplot(3, 1, 2)
plot(t, r_t); xlabel("t"); legend("r(t)");

% [接收]
y_t = r_t; % y_t 经过接收机后的波形
subplot(3, 1, 3)
plot(t, y_t); xlabel("t"); legend("y(t)");

% 采样/判决
y_n = zeros(1, length(a_k)); % y_n 采样得到的比特序列

for n = 1:length(a_k)
    y_n(n) = y_t(n * Ts / precision);
end

fprintf("y_n"); disp(y_n);

% [分析]
t_range = [0, 10];
t_N = (t_end - t_start) / precision;
omega_range = [-10, 10];
omega_N = 10000;

[t, omg, FT, IFT] = prefourier(t_range, t_N, omega_range, omega_N);
figure(); plot(omg, abs(FT * s_t')); xlabel("\omega"); legend("F(s_t)")
