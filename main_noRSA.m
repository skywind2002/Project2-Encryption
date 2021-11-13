% 用升余弦滤波器进行收发

clear;close all;clc;

%% parameters
SNR = 0; % 给定信噪比
% TODO b_n -> a_n 的映射是可以调整的，也就是那些 MASK MPSK MQAM MFSK
SK_way = 'BASK';

%% constants
f_low = 300; omega_low = f_low * 2 * pi;
f_high = 3400; omega_high = f_high * 2 * pi;
f_0 = (f_high + f_low) / 2; omega_0 = f_0 * 2 * pi;
W = (f_high - f_low) / 2; % W 升余弦滤波器中的W 最右边的那个点 约等于1500Hz
alpha = 0.5;
Ts = (alpha + 1) / 2 / W; % 采样间隔 (s)
Rs = 1 / Ts;
% `alpha = 2*W*Ts - 1 = 0.5`
% 这里采样间隔相当于传输两个符号之间的间隔 1s可以传2000个符号
% 题目要求为8000bit 要在5s内传完
% 直接传比特也是可以的 但是加上卷积码或者检错码可能就不够了
subplot_r = 4; subplot_c = 2; % subplot作图

%% 【生成比特流】
message = randi([0, 1], 1, 60);

if rem(length(message), 16) ~= 0
    % 不是16的整数倍 补零
    message = [message, repmat([0], 1, 16 - rem(length(message), 16))];
end

%% 【发送】

% 符号调制
switch SK_way
    case 'BASK'
        a_n = SK_BASK(message); % a_n 要发送的比特序列
    otherwise
        assert(0, "没有所选择的符号映射方式");
end

%% prefourier
t_start = 0; t_end = Ts * length(a_n) * 1.2;
precision_N = 3; precision = Ts / precision_N; % 时频信号MATLAB计算精度
omega_range = [-1.5 * omega_high, 1.5 * omega_high]; % 这里做频域分析，至少范围要大于 ±omega_high
omega_N = 8000;
t_range = [t_start, t_end];
t_N = (t_end - t_start) / precision;
T = t_range(2) - t_range(1);
t = linspace(t_range(1), t_range(2) - T / t_N, t_N)';
OMG = omega_range(2) - omega_range(1);
omg = linspace(omega_range(1), omega_range(2) - OMG / omega_N, omega_N)';
t = t'; % 大多使用行向量

%% ——升余弦滤波器——
s_len = min(2 * length(a_n), 128);
t_raisedcos = rcosdesign(alpha, s_len, precision_N, 'sqrt'); % 生成根号升余弦的时域波形，一共 s_len * precision_N + 1个采样点，最中间的采样点对应 t = 0 时刻
t_raisedcos = t_raisedcos / max(t_raisedcos); % 默认生成的 t_raisedcos 能量为 1，我们希望它的中心振幅为 1。

%% 【冲激调制序列】
a_t = zeros(1, length(t)); % a_t 冲激调制得到的序列

for n = 1:length(a_n)
    a_t(n * precision_N) = a_n(n); % 用时间宽度为 precision 的求和代替积分时，delta 应当取高度为 1/precision 使得求和结果为 1
end

% 时域
figure(1); subplot(subplot_r, subplot_c, 1);
plot(t(t < 20 * Ts), a_t(t < 20 * Ts)); xlabel("t"); legend("a(t)");
hold on; stem((1:20) * Ts - precision, a_t((1:20) * precision_N)); hold off;
% 频域
figure(1); subplot(subplot_r, subplot_c, 2);
[P, f] = power_spectrum(a_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); legend("F(a(t))")

%% 【a(t)通过发射滤波器】
s_t = upfirdn(a_t, t_raisedcos); % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
delay = (length(t_raisedcos) - 1) / 2;
s_t = s_t(delay + 1:end - delay);

figure(1); subplot(subplot_r, subplot_c, 3);
plot(t(t < 20 * Ts), s_t(t < 20 * Ts)); xlabel("t");
hold on; stem((1:20) * Ts - precision, s_t((1:20) * precision_N)); hold off;
legend("s(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 4);
[P, f] = power_spectrum(s_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); legend("F(s(t))")

%% 【升频】TODO 直接乘cos 注意写成复数的形式 这样之后复数也可以直接用
u_t = s_t .* cos(omega_0 * t);

%% 【信道传输】信道本身是带通 而且要附加噪声
r_t = u_t;
r_t = awgn(r_t, SNR, 'measured'); % awgn附加高斯噪声 信号能量由MATLAB计算得到

figure(1); subplot(subplot_r, subplot_c, 5);
plot(t(t < 20 * Ts), r_t(t < 20 * Ts)); xlabel("t");
hold on; stem((1:20) * Ts - precision, r_t((1:20) * precision_N)); hold off;
legend("r(t)", "(采样点)");
figure(1); subplot(subplot_r, subplot_c, 6);
[P, f] = power_spectrum(r_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); legend("F(r(t))")

%% 【降频】TODO 乘以cos再过理想低通 注意1/2系数？
w_t = 2 * r_t .* cos(omega_0 * t); % 接受滤波器的根号升余弦就是低通了，这里不用过一次低通

%% 【接收】
y_t = upfirdn(w_t, t_raisedcos) / precision_N; % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
delay = (length(t_raisedcos) - 1) / 2;
y_t = y_t(delay + 1:end - delay);

figure(1); subplot(subplot_r, subplot_c, 7);
plot(t(t < 20 * Ts), y_t(t < 20 * Ts)); xlabel("t");
hold on; stem((1:20) * Ts - precision, y_t((1:20) * precision_N)); hold off;
legend("y(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 8);
[P, f] = power_spectrum(y_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); legend("F(y(t))")

%% 【采样】
y_n = zeros(1, length(a_n)); % y_n 采样得到的比特序列

for n = 1:length(a_n)
    y_n(n) = y_t(n * precision_N);
end

%% 【判决】
message_rec = zeros(1, length(a_n)); % message_rec 判决后得到的离散序列

switch SK_way
    case 'BASK'
        message_rec = SKi_BASK(y_n); % a_n 要发送的比特序列
    otherwise
        assert(0, "没有所选择的符号映射方式");
end

fprintf("message_rec"); disp(message_rec);
figure(2); stem(message_rec ~= message); title("传输总过程中的误码图案");
