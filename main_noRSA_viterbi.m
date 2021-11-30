% 用升余弦滤波器进行收发

clear;close all;clc;

%% parameters
SNR = 20; % 给定信噪比
% b_n -> a_n 的映射是可以调整的 MASK/MPSK
SK_way = 'PSK';
SK_M = 8;

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

%% 作图
subplot_r = 5; subplot_c = 3; % subplot作图
frequency_range = [-1.5 * f_high, 1.5 * f_high];

%% 【生成比特流】
message = randi([0, 1], 1, 24); % message 要发送的比特序列 8192

if rem(length(message), 12) ~= 0 % 12 = 3 * 4 用4种进制数都可以
    % 不是12的整数倍 补零
    message = [message, repmat([0], 1, 12 - rem(length(message), 12))];
end

%% 【发送】
%% 卷积码编码
n = log2(SK_M); k = 1; m = 4;
% 注意这里n=2的话就选QPSK n=3的话就选8PSK 因为软解的话这两个值必须相同
A = cat(3, [1 1 1], [1 0 1], [0 1 1], [1 1 1]);
zero_begin = 1; % 从零状态开始
zero_end = 1; % 收尾
p = 2; % 有限域中的符号数 这里符号都是二元的
viterbi_mode = 0; % 0 hard 1 soft % TODO 软判
conv_encoded_message = conv_encode(message, n, k, m, A, zero_begin, zero_end, p);

%% 符号调制
% a_n 要发送的符号序列
switch SK_way
    case 'PSK'
        r = 1;
        amplitude_range = [-r * 1.5, r * 1.5];
        a_n = PSK(conv_encoded_message, SK_M, r);
    otherwise
        assert(0, "没有所选择的符号映射方式");
end

%% prefourier
t_start = 0; t_end = Ts * length(a_n) * 1.2;
precision_N = 8; precision = Ts / precision_N; % 时频信号MATLAB计算精度 % precision_N取3不太够用 当使用16ASK的时候 高信噪比下还是得提高精度
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
t_raisedcos = 1.14 * t_raisedcos / max(t_raisedcos); % 默认生成的 t_raisedcos 能量为 1，我们希望它的中心振幅为 1。
% FIXME 这里1.14的原理？

%% 【冲激调制序列】
a_t = zeros(1, length(t)); % a_t 冲激调制得到的序列

for kk = 1:length(a_n)
    a_t(kk * precision_N) = a_n(kk); % 用时间宽度为 precision 的求和代替积分时，delta 应当取高度为 1/precision 使得求和结果为 1
end

% 时域
figure(1); subplot(subplot_r, subplot_c, 1);
plot(t(t < 20 * Ts), real(a_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, real(a_t((1:20) * precision_N))); hold off; legend("a(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 2);
plot(t(t < 20 * Ts), imag(a_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, imag(a_t((1:20) * precision_N))); hold off; legend("a(t)", "采样点");
% 频域
figure(1); subplot(subplot_r, subplot_c, 3);
[P, f] = power_spectrum(a_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); xlim(frequency_range); legend("F(a(t))");

%% 【a(t)通过发射滤波器】
s_t = upfirdn(a_t, t_raisedcos); % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
delay = (length(t_raisedcos) - 1) / 2;
s_t = s_t(delay + 1:end - delay);

figure(1); subplot(subplot_r, subplot_c, 4);
plot(t(t < 20 * Ts), real(s_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, real(s_t((1:20) * precision_N))); hold off; legend("s(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 5);
plot(t(t < 20 * Ts), imag(s_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, imag(s_t((1:20) * precision_N))); hold off; legend("s(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 6);
[P, f] = power_spectrum(s_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); xlim(frequency_range); legend("F(s(t))")

%% 【升频】写成复数的形式
u_t = s_t .* exp(1j * (omega_0 * t));
u_t = real(u_t);
figure(1); subplot(subplot_r, subplot_c, 7);
plot(t(t < 20 * Ts), real(u_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, real(u_t((1:20) * precision_N))); hold off; legend("u(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 8);
plot(t(t < 20 * Ts), imag(u_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, imag(u_t((1:20) * precision_N))); hold off; legend("u(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 9);
[P, f] = power_spectrum(u_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); xlim(frequency_range); legend("F(u(t))")

%% 【信道传输】信道本身是带通 而且要附加噪声
r_t = awgn(u_t, SNR, 'measured'); % awgn附加高斯噪声 信号能量由MATLAB计算得到

figure(1); subplot(subplot_r, subplot_c, 10);
plot(t(t < 20 * Ts), real(r_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, real(r_t((1:20) * precision_N))); hold off; legend("r(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 11);
plot(t(t < 20 * Ts), imag(r_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, imag(r_t((1:20) * precision_N))); hold off; legend("r(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 12);
[P, f] = power_spectrum(r_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); xlim(frequency_range); legend("F(r(t))")

%% 【降频】乘以exp(jwt)再过理想低通
w_t = 2 * r_t .* exp(-1j * (omega_0 * t)); % 接受滤波器的根号升余弦就是低通了，这里不用过一次低通

%% 【接收】
y_t = upfirdn(w_t, t_raisedcos) / precision_N; % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
delay = (length(t_raisedcos) - 1) / 2;
y_t = y_t(delay + 1:end - delay);

figure(1); subplot(subplot_r, subplot_c, 13);
plot(t(t < 20 * Ts), real(y_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, real(y_t((1:20) * precision_N))); hold off; legend("y(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 14);
plot(t(t < 20 * Ts), imag(y_t(t < 20 * Ts))); xlabel("t"); ylim(amplitude_range);
hold on; stem((1:20) * Ts - precision, imag(y_t((1:20) * precision_N))); hold off; legend("y(t)", "采样点");
figure(1); subplot(subplot_r, subplot_c, 15);
[P, f] = power_spectrum(y_t, precision, 1024);
plot(f, 10 * log10(P)); xlabel("f/Hz"); xlim(frequency_range); legend("F(y(t))")

%% 【采样】
y_n = zeros(1, length(a_n)); % y_n 采样得到的符号序列

for kk = 1:length(a_n)
    y_n(kk) = y_t(kk * precision_N);
end

%% 【判决】
message_rec = zeros(1, length(a_n)); % message_rec 判决后得到的比特序列

switch SK_way
    case 'PSK'

        if viterbi_mode == 0 % hard
            message_rec = iPSK(y_n, SK_M); % 注意 这一步将采样得到的实数接受序列变成了01比特流（对应卷积码编码结束后的conv_encoded_message）
            message_rec = viterbi_decode(message_rec, n, k, m, A, viterbi_mode, p); % 传入的message_rec是01序列
            message_rec = message_rec(1:length(message)); % 因为只使用收尾的所以要去掉尾零
        else % soft
            % TODO
            disp("TODO")
        end

    otherwise
        assert(0, "没有所选择的符号映射方式");
end

% fprintf("message_rec(1:16)"); disp(message_rec(1:16));
figure(2); stem(message_rec ~= message); title("传输总过程中的误码图案");
