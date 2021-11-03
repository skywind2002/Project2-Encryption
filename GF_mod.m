%% 计算有限域 GF(p) 上的多项式取模
% 此函数类似于 deconv，但是是在有限域 GF(p) 上进行的。最终返回余数 r 和商 q。
% u - 被除数。输入行向量，最大权重位在最前面。若 u 为矩阵，则对 u 的每行分别计算。
% v - 除数。输入行向量，最大权重位在最前面。
% p - 域中元素的个数。
% r - 余数。输出行向量，最大权重位在最前面。
% q - 商。输出行向量，最大权重位在最前面。若 u 有多行，则 q,r 也有相同的行数。
function [r, q] = GFp_deconv(u, v, p)
    % 计算 ax==1(mod p) 的解 x=vinv，其中 a=v(1)。
    vinv = 0;
    for k = 1:p - 1
        if (mod(v(1) * k, p) == 1)
            vinv = k; 
            break;
        end
    end

    vlen = size(v, 2);
    ulen = size(u, 2);
    q = zeros(size(u, 1), ulen - vlen + 1);
    for t = 1:ulen - vlen + 1
        q(:, t) = mod(vinv * u(:, t), p);
        u(:, t:t + vlen - 1) = mod(u(:, t:t + vlen - 1) - v .* q(:, t), p);
    end

    r = u(:, ulen - vlen + 2:ulen);
end
