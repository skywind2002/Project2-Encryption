% 用升余弦滤波器进行收发

clear;close all;clc;

%% parameters
message_length = 8192;
% 令SNR为0得到 Ebno = 0.3784
Ebn0_array = [0.01, 0.1:0.1:5];
SNR_array = 10 * log10(message_length / 3100 * Ebn0_array); % 给定信噪比
BER_array = zeros(1, length(Ebn0_array));

experiment_times = 16;

for times = 1:experiment_times

    for k = 1:length(Ebn0_array)
        SNR = SNR_array(k);

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
        message = randi([0, 1], 1, message_length); % message 要发送的比特序列

        if rem(length(message), 12) ~= 0 % 12 = 3 * 4 用4种进制数都可以
            % 不是12的整数倍 补零
            message = [message, repmat([0], 1, 12 - rem(length(message), 12))];
        end

        %% 【发送】

        % 符号调制
        % a_n 要发送的符号序列
        switch SK_way
            case 'ASK'
                amplitude_range = [-1, SK_M + 1];
                a_n = ASK(message, SK_M);
            case 'PSK'
                r = 1;
                amplitude_range = [-r * 1.5, r * 1.5];
                a_n = PSK(message, SK_M, r);
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

        for n = 1:length(a_n)
            a_t(n * precision_N) = a_n(n); % 用时间宽度为 precision 的求和代替积分时，delta 应当取高度为 1/precision 使得求和结果为 1
        end

        %% 【a(t)通过发射滤波器】
        s_t = upfirdn(a_t, t_raisedcos); % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
        delay = (length(t_raisedcos) - 1) / 2;
        s_t = s_t(delay + 1:end - delay);

        %% 【升频】写成复数的形式
        u_t = s_t .* exp(1j * (omega_0 * t));
        u_t = real(u_t);

        %% 【信道传输】信道本身是带通 而且要附加噪声
        r_t = awgn(u_t, SNR, 'measured'); % awgn附加高斯噪声 信号能量由MATLAB计算得到

        %% 【降频】乘以exp(jwt)再过理想低通
        w_t = 2 * r_t .* exp(-1j * (omega_0 * t)); % 接受滤波器的根号升余弦就是低通了，这里不用过一次低通

        %% 【接收】
        y_t = upfirdn(w_t, t_raisedcos) / precision_N; % 用根号升余弦滤波，upfirdn 知道 t_raisedcos 的中间点对应 t=0，因此会在结果前后各引入多余的 (length(t_raisedcos) - 1) / 2 个点
        delay = (length(t_raisedcos) - 1) / 2;
        y_t = y_t(delay + 1:end - delay);

        %% 【采样】
        y_n = zeros(1, length(a_n)); % y_n 采样得到的符号序列

        for n = 1:length(a_n)
            y_n(n) = y_t(n * precision_N);
        end

        %% 【判决】
        message_rec = zeros(1, length(a_n)); % message_rec 判决后得到的比特序列

        switch SK_way
            case 'ASK'
                message_rec = iASK(y_n, SK_M);
            case 'PSK'
                message_rec = iPSK(y_n, SK_M);
            otherwise
                assert(0, "没有所选择的符号映射方式");
        end

        BER = sum(message_rec ~= message) / message_length;
        BER_array(k) = BER_array(k) + BER;

        % fprintf("Eb/n0 = %f; ", Ebn0_array(k))
        % fprintf("SNR = %f; ", SNR)
        % fprintf("BER = %f.\n", BER)

    end

end

BER_array = BER_array / experiment_times;

subplot(1, 2, 1);
loglog(Ebn0_array, BER_array, "x-"); xlabel("E_b/n_0"); ylabel("BER");
subplot(1, 2, 2);
semilogy(SNR_array, BER_array, "o-"); xlabel("SNR (dB)"); ylabel("BER");

disp(BER_array)
