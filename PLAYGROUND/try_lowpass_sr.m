% 尝试用低通滤波器收发实信号

clear;close all;clc;

%% parameters
Ts = 1; % 采样间隔 (s)
subplot_r = 6; subplot_c = 2;

%% prefourier
precision = 0.005;
t_start = 0;
t_end = 10;
t_range = [t_start, t_end];
t_N = (t_end - t_start) / precision;
omega_range = [-10, 10];
omega_N = 2000;
[t, omg, FT, IFT] = prefourier(t_range, t_N, omega_range, omega_N);
t = t'; % 大多使用行向量

%% 【发送】
a_n = [0, 1, 1, 0, 1, 0, 1, 1]; % a_n 要发送的比特序列

%% 【冲激调制序列】
a_t = zeros(1, length(t)); % a_t 冲激调制得到的序列

for n = 1:length(a_n)
    a_t(n * Ts / precision) = a_n(n) * 1000; % 这里乘系数1000表示delta函数
end

% 时域
figure(1); subplot(subplot_r, subplot_c, 1);
plot(t, a_t); xlabel("t"); legend("a(t)");
% 频域
figure(1); subplot(subplot_r, subplot_c, 2);
plot(omg, abs(FT * a_t')); xlabel("\omega"); legend("F(a(t))")

%% 【a(t)通过发射滤波器（这里使用低通滤波器，后面替换为根号升余弦）】
w_c = pi; % 低通滤波器截止角频率给出
s_t = IFT * (FT * a_t' .* (omg > -w_c & omg < w_c));
s_t = real(s_t');

figure(1); subplot(subplot_r, subplot_c, 3);
plot(t, s_t); xlabel("t"); legend("s(t)");
figure(1); subplot(subplot_r, subplot_c, 4);
plot(omg, abs(FT * s_t')); xlabel("\omega"); legend("F(s(t))")

%% 【信道传输】信道本身是低通或者带通（大作业是带通）而且要附加噪声 这里先写成低通

w_c_channel = w_c;
r_t = IFT * (FT * s_t' .* (omg > -w_c_channel & omg < w_c_channel)); % r_t 经过信道后的波形
r_t = real(r_t');

SNR = 0; % 给定信噪比
r_t = awgn(r_t, SNR, 'measured'); % 信号能量由MATLAB计算得到

figure(1); subplot(subplot_r, subplot_c, 5);
plot(t, r_t); xlabel("t"); legend("r(t)");
figure(1); subplot(subplot_r, subplot_c, 6);
plot(omg, abs(FT * r_t')); xlabel("\omega"); legend("F(r(t))") % `FT * r_t'` 和 `FT * a_t' .* (omg > -w_c & omg < w_c)` 有一些差异，可能是因为IFT*FT不是单位阵 而且限制时域和频域的范围相当于加窗……

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
    y_n(n) = y_t(n * Ts / precision);
end

fprintf("y_n"); disp(y_n);
figure(1); subplot(subplot_r, subplot_c, 9);
stem(y_n);legend("y[n]")

%% 【判决】
yy_n = zeros(1, length(a_n)); % yy_n 判决后得到的离散序列

for n = 1:length(a_n)
    % 只有两个值可以用门限判断 % FIXME 最终得到的波形和最开始的相差幅度比较严重(和s_t是很相近的)，不然可以一开始就确定判决门限
    if abs(y_n(n)) < 2
        yy_n(n) = 0;
    else
        yy_n(n) = 1;
    end

end

fprintf("yy_n"); disp(yy_n);
figure(1); subplot(subplot_r, subplot_c, 11);
stem(yy_n);legend("yy[n]")
