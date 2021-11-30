%% 对 r 计算以 A 为参数的 (n, k, m) 卷积码的维特比解码。A 是 k*n*m 矩阵，r 是行向量，表示待解码码流。
% r - 行向量，表示待编码符号流。
% n - 每组编码后长度
% k - 每组长度
% m - 卷积深度（组数）
% A - 卷积参数，表示 m 个 k*n 的矩阵。如果有 m 个 k*n 的矩阵 A1, A2, ..., Am，如 m = 5，则可以调用 A = cat(3, A1, A2, A3, A4, A5); 得到这里的参数 A。
% mode - 0: hard viterbi 1: soft viterbi
% p - 有限域中的符号数
function decode = viterbi_decode(r, n, k, m, A, mode, p)

    if (mode == 0) % Hard Viterbi
        r = [r, zeros(1, mod(-length(r), n))]; % 补零变成 n 的倍数
        r = reshape(r, n, []); % 化为若干列，每一列都对应于 k 个原符号（共依赖于 m*k 个原符号）

        distance = @(b, a)(hard_distance(b, a, 2));
    else
        % TODO: 这里只用了8PSK 不清楚这个是不是和yxj写的不一样
        Gray_code = [0 1 3 2 7 6 4 5];
        r = 1;
        mapping = r * exp(1j * pi * Gray_code / 4);
        distance = @(z, y)(soft_distance(z, y, mapping, 2));
    end

    n_decode = size(r, 2) * k; % 最终输出的码流长度

    n_state = p^(m - 1); % 米利机状态数，p种情形在输入中，p^{m-1} 种情形在状态中
    state = dec2base(0:n_state - 1, p, m - 1) - '0'; % n_state * (m-1) 矩阵，每一行对应一个长度为 m-1 的状态
    total_dis = [0, Inf + zeros(1, n_state - 1)]'; % 总距离。因为从状态为 0 开始，所以取第一个为 0、其余的为 Inf。
    route = zeros(n_state, size(r, 2)); % 存储最优路径，每一行都是一条走到相应 state 的最优路径。

    for i = 1:size(r, 2)
        input = r(:, i).'; % 当前处理的输入
        next_dis = zeros(size(total_dis)); % 缓存下一个状态的最短距离
        next_route = zeros(size(route)); % 缓存下一个状态的最优路径

        try_input = 0:p - 1; % 假想的输入，这里默认了 k = 1
        full_input = reshape(repmat(try_input, n_state, 1), [], 1); % 每个元素重复 n_state 次
        full_state = [repmat(state, p, 1), full_input]; % 状态+假想输入得到的完整输入，第 k * n_state + s + 1 行表示第 s 个状态和第 k 个输入的组合
        raw_dis = repmat(total_dis, p, 1); % 每个 full_state 对应的原距离
        output = convs(n, k, m, A, full_state, p);
        delta_dis = distance(input, output); % 实际的 input 和各个假想的 output 之间的距离
        next_state = full_state(:, 2:end); % 各个状态在 try_input 的假想输入下对应的下一个状态
        next_state = base2dec(char(next_state + '0'), p) + 1; % 转换为索引，next_state 中各种状态应恰好出现 p 次

        for s = 1:n_state % 遍历各个次状态
            state_k = (next_state == s); % 取出 next_state 中的 p 个相应状态
            rd = raw_dis(state_k); % 原来的距离
            dd = delta_dis(state_k); % 增加的距离
            td = rd + dd; % 总距离
            [next_dis(s), I] = min(td); % 最小距离作为状态 s 的总距离
            tmp = find(state_k, I(1));
            index = mod(tmp(end) - 1, n_state) + 1;
            route_k = route(index, :);
            input_k = full_input(state_k);
            next_route(s, 1:i) = [route_k(1:i - 1), input_k(I(1))];
        end

        route = next_route;
        total_dis = next_dis;
    end

    decode = route(1, :);

    % TODO: 编码时收尾的话要去尾零
end
