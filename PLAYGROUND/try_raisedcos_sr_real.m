% 尝试用升余弦滤波器收发实信号

clear;close all;clc;

%% parameters
% TODO b_n -> a_n 的映射是可以调整的，也就是那些 MASK MPSK MQAM MFSK
SNR = 20; % 给定信噪比

%% constants
f_low = 300; W_low = f_low * 2 * pi;
f_high = 3400; W_high = f_high * 2 * pi;
W = (f_high - f_low) / 2; % W 升余弦滤波器中的W 最右边的那个点 约等于1500Hz
alpha = 0.5;
Ts = (alpha + 1) / 2 / W; % 采样间隔 (s)
% `alpha = 2*W*Ts - 1 = 0.5`
% 这里采样间隔相当于传输两个符号之间的间隔 1s可以传2000个符号
% 题目要求为8000bit 要在5s内传完
% 直接传比特也是可以的 但是加上卷积码或者检错码可能就不够了
subplot_r = 6; subplot_c = 2; % subplot作图

%% prefourier
t_start = 0; t_end = 0.01; precision = Ts / 16; % 时频信号MATLAB计算精度
omega_range = [-2 * W_high, 2 * W_high]; % 这里做频域分析，至少范围要大于 ±W_high
omega_N = 16000;
t_range = [t_start, t_end];
t_N = (t_end - t_start) / precision;
[t, omg, FT, IFT] = prefourier(t_range, t_N, omega_range, omega_N);
t = t'; % 大多使用行向量

%% ——升余弦滤波器——
% TODO

%% 【发送】
a_n = [0, 1, 1, 0, 1, 0, 1, 1]; % a_n 要发送的比特序列

%% 【冲激调制序列】
a_t = zeros(1, length(t)); % a_t 冲激调制得到的序列

for n = 1:length(a_n)
    a_t(int32(n * Ts / precision)) = a_n(n) * 1000; % 这里乘系数1000表示delta函数
end

% 时域
figure(1); subplot(subplot_r, subplot_c, 1);
plot(t, a_t); xlabel("t"); legend("a(t)");
% 频域
figure(1); subplot(subplot_r, subplot_c, 2);
plot(omg, abs(FT * a_t')); xlabel("\omega"); legend("F(a(t))")

%% 【a(t)通过发射滤波器（这里使用低通滤波器，后面替换为根号升余弦）】
w_c = W_high; % 低通滤波器截止角频率给出
s_t = IFT * (FT * a_t' .* (omg > -w_c & omg < w_c));
s_t = real(s_t');

figure(1); subplot(subplot_r, subplot_c, 3);
plot(t, s_t); xlabel("t"); legend("s(t)");
figure(1); subplot(subplot_r, subplot_c, 4);
plot(omg, abs(FT * s_t')); xlabel("\omega"); legend("F(s(t))")

%% 【升频】TODO

%% 【信道传输】信道本身是低通或者带通（大作业是带通）而且要附加噪声 这里先写成低通

w_c_channel = w_c;
r_t = IFT * (FT * s_t' .* (omg > -w_c_channel & omg < w_c_channel)); % r_t 经过信道后的波形
r_t = real(r_t');

r_t = awgn(r_t, SNR, 'measured'); % 信号能量由MATLAB计算得到

figure(1); subplot(subplot_r, subplot_c, 5);
plot(t, r_t); xlabel("t"); legend("r(t)");
figure(1); subplot(subplot_r, subplot_c, 6);
plot(omg, abs(FT * r_t')); xlabel("\omega"); legend("F(r(t))") % `FT * r_t'` 和 `FT * a_t' .* (omg > -w_c & omg < w_c)` 有一些差异，可能是因为IFT*FT不是单位阵 而且限制时域和频域的范围相当于加窗……

%% 【降频】TODO

%% 【接收】
y_t = IFT * (FT * r_t' .* (omg > -w_c & omg < w_c)); % y_t 经过接收机后的波形 % 使用和发射滤波器同样的低通截止角频率
y_t = real(y_t');

figure(1); subplot(subplot_r, subplot_c, 7);
plot(t, y_t); xlabel("t"); legend("y(t)");
figure(1); subplot(subplot_r, subplot_c, 8);
plot(omg, abs(FT * y_t')); xlabel("\omega"); legend("F(y(t))") % `figure();plot(t,y_t-s_t);` 可以看到和原始信号有多大差异 将SNR设置到-20能看到明显差异 可能还与Ts有关，这里Ts实在是太大了(1s)
% figure(); plot(t, y_t - s_t); title("y(t)-s(t)")

%% 【采样】
y_n = zeros(1, length(a_n)); % y_n 采样得到的比特序列

for n = 1:length(a_n)
    y_n(n) = y_t(int16(n * Ts / precision));
end

fprintf("y_n"); disp(y_n);
figure(1); subplot(subplot_r, subplot_c, 9);
stem(y_n); legend("y[n]")

%% 【判决】
yy_n = zeros(1, length(a_n)); % yy_n 判决后得到的离散序列

for n = 1:length(a_n)
    % 只有两个值可以用门限判断 % FIXME 最终得到的波形和最开始的相差幅度比较严重(和s_t是很相近的)，不然可以一开始就确定判决门限
    % TODO 修改判决方法
    if abs(y_n(n)) < 2
        yy_n(n) = 0;
    else
        yy_n(n) = 1;
    end

end

fprintf("yy_n"); disp(yy_n);
figure(1); subplot(subplot_r, subplot_c, 11);
stem(yy_n); legend("yy[n]")
