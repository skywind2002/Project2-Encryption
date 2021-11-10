%% 对 data 计算以 A 为参数的 (n, k, m) 卷积码。A 是 k*n*m 矩阵，data 是行向量，表示待编码码流。
% data - 行向量，表示待编码符号流。若为矩阵，则对每个行向量进行卷积编码
% n - 每组编码后长度
% k - 每组长度
% m - 卷积深度（组数）
% A - 卷积参数，表示 m 个 k*n 的矩阵。如果有 m 个 k*n 的矩阵 A1, A2, ..., Am，如 m = 5，则可以调用 A = cat(3, A1, A2, A3, A4, A5); 得到这里的参数 A。
% zero_begin - 是否从零状态开始
% zero_end - 结尾是否收零
% p - 有限域中的符号数
function y = conv_encoding(data, n, k, m, A, zero_begin, zero_end, p)
    assert(all(size(A) == [k, n, m]), "A 应为 k*n*m 矩阵！")
    A = double(reshape(permute(A, [1, 3, 2]), m * k, n)); % 化为 m*k 行 n 列矩阵方便后续计算
    N = size(data, 1); % data 的行数，即要同时处理的码流数量
    len = ceil(size(data, 2) / k); % data 的组数
    data = [data, zeros(N, len * k - length(data))]; % 补零使得 data 长度为 k 的整数倍
    if(zero_begin == 1)
        data = [zeros(N, k * (m - 1)), data]; % 前面补 (m - 1) 组零，从零状态开始
        len = len + m - 1; % 从零状态开始会导致增加 (m - 1) 组
    end
    if(zero_end == 1)
        data = [data, zeros(N, k * (m - 1))]; % 后面补 (m - 1) 组零收尾
        len = len + m - 1; % 收尾会导致增加 (m - 1) 组
    end

    y = zeros(N, (len - m + 1) * n);
    for t = m:len % 逐组计算
        y(:, (t - m) * n + 1:(t - m + 1) * n) = data(:, (t - m) * k + 1:t * k) * A; 
    end

    y = mod(y, p);
end