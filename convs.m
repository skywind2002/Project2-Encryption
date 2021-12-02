%% 同时对多个行向量 x 计算以 A 为参数的 (n, k, m) 卷积码，并且不补零收尾。A 是 k*n*m 矩阵。
% 注：如果有 m 个 k*n 的矩阵 A1, A2, ..., Am，如 m = 5，则可以调用
% A = cat(3, A1, A2, A3, A4, A5);
% 得到这里的参数 A。
function y = convs(n, k, m, A, x, p)

    if (nargin == 5)
        p = 2;
    end

    assert(all(size(A) == [k, n, m]), "A 应为 k*n*m 矩阵！")
    A = reshape(permute(A, [1, 3, 2]), m * k, n); % 化为 m*k 行 n 列矩阵方便后续计算
    y = mod(double(x) * A, p);
end
