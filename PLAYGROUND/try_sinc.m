clear;close all;clc;

Ts = 1; % 采样间隔 (s)
precision = 0.01;
t = (0 + precision):(precision):(10);

a_k = [0, 1, 1, 0, 1, 0, 1]; % 要发送的比特序列
s_t = zeros(1, length(t)); % 发送的波形：由比特序列调制得到

for n = 1:length(a_k)
    s_t = a_k(n) * sinc(t - n * Ts)  + s_t;
end

subplot(2, 1, 1)
plot(t, s_t)

% channel
r_t = s_t; % r_t 经过信道后的波形
y_t = r_t; % y_t 经过接收机后的波形
y_n = zeros(1, length(a_k)); % y_n 采样得到的比特序列

for n = 1:length(a_k)
    y_n(n) = y_t(n * Ts / precision);
end

disp(y_n)
