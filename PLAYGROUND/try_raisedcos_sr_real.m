% 用升余弦滤波器收发实信号

clear;close all;clc;

%% parameters
% TODO b_n -> a_n 的映射是可以调整的，也就是那些 MASK MPSK MQAM MFSK
SNR = 20; % 给定信噪比
% 【发送】
a_n = [0, 1, 1, 0, 1, 0, 1, 1]; % a_n 要发送的比特序列

%% constants
f_low = 300; omega_low = f_low * 2 * pi;
f_high = 3400; omega_high = f_high * 2 * pi;
W = (f_high - f_low) / 2; % W 升余弦滤波器中的W 最右边的那个点 约等于1500Hz
alpha = 0.5;
Ts = (alpha + 1) / 2 / W; % 采样间隔 (s)
% `alpha = 2*W*Ts - 1 = 0.5`
% 这里采样间隔相当于传输两个符号之间的间隔 1s可以传2000个符号
% 题目要求为8000bit 要在5s内传完
% 直接传比特也是可以的 但是加上卷积码或者检错码可能就不够了
subplot_r = 4; subplot_c = 2; % subplot作图

%% prefourier
t_start = 0; t_end = Ts * length(a_n) * 1.2;
precision_N = 16; precision = Ts / precision_N; % 时频信号MATLAB计算精度
omega_range = [-1.5 * omega_high, 1.5 * omega_high]; % 这里做频域分析，至少范围要大于 ±omega_high
omega_N = 8000;
t_range = [t_start, t_end];
t_N = (t_end - t_start) / precision;
[t, omg, FT, IFT] = prefourier(t_range, t_N, omega_range, omega_N);
t = t'; % 大多使用行向量

%% ——升余弦滤波器——
omega_raisedcos = risecos(omg / (2 * pi), W, alpha);

%% 【冲激调制序列】
a_t = zeros(1, length(t)); % a_t 冲激调制得到的序列

for n = 1:length(a_n)
    a_t(n * precision_N) = a_n(n) / precision; % 用时间宽度为 precision 的求和代替积分时，delta 应当取高度为 1/precision 使得求和结果为 1
end

% 时域
figure(1); subplot(subplot_r, subplot_c, 1);
plot(t, a_t); xlabel("t"); legend("a(t)");
% 频域
figure(1); subplot(subplot_r, subplot_c, 2);
plot(omg, abs(FT * a_t').^2); xlabel("\omega"); legend("F(a(t))")

%% 【a(t)通过发射滤波器】
s_t = IFT * (FT * a_t' .* sqrt(omega_raisedcos));
s_t = real(s_t'); % 计算精度会出现很小的虚部 直接取实部就好了

figure(1); subplot(subplot_r, subplot_c, 3);
plot(t, s_t); xlabel("t");
hold on; stem((1:length(a_n)) * Ts, s_t((1:length(a_n)) * precision_N + 1)); hold off;
legend("s(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 4);
plot(omg, abs(FT * s_t').^2); xlabel("\omega"); legend("F(s(t))")

%% 【升频】TODO 直接乘cos 注意写成复数的形式 这样之后复数也可以直接用

%% 【信道传输】信道本身是带通 而且要附加噪声
% TODO  这里先写成低通 需要改成带通
w_c_channel = omega_high;
r_t = IFT * (FT * s_t' .* (omg > -w_c_channel & omg < w_c_channel)); % r_t 经过信道后的波形
r_t = real(r_t');
r_t = awgn(r_t, SNR, 'measured'); % awgn附加高斯噪声 信号能量由MATLAB计算得到

figure(1); subplot(subplot_r, subplot_c, 5);
plot(t, r_t); xlabel("t");
hold on; stem((1:length(a_n)) * Ts, r_t((1:length(a_n)) * precision_N + 1)); hold off;
legend("r(t)", "(采样点)");
figure(1); subplot(subplot_r, subplot_c, 6);
plot(omg, abs(FT * r_t').^2); xlabel("\omega"); legend("F(r(t))")

%% 【降频】TODO 乘以cos再过理想低通 注意1/2系数？

%% 【接收】
y_t = IFT * (FT * r_t' .* sqrt(omega_raisedcos)); % y_t 经过接收机后的波形 % 使用和发射滤波器同样的低通截止角频率
y_t = real(y_t');

figure(1); subplot(subplot_r, subplot_c, 7);
plot(t, y_t); xlabel("t");
hold on; stem((1:length(a_n)) * Ts, y_t((1:length(a_n)) * precision_N + 1)); hold off;
legend("y(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 8);
plot(omg, abs(FT * y_t').^2); xlabel("\omega"); legend("F(y(t))")

%% 【采样】
y_n = zeros(1, length(a_n)); % y_n 采样得到的比特序列

for n = 1:length(a_n)
    y_n(n) = y_t(n * precision_N);
end

fprintf("y_n"); disp(y_n);

%% 【判决】
yy_n = zeros(1, length(a_n)); % yy_n 判决后得到的离散序列

for n = 1:length(a_n)
    if abs(y_n(n)) < 0.5
        yy_n(n) = 0;
    else
        yy_n(n) = 1;
    end
end

fprintf("yy_n"); disp(yy_n);
