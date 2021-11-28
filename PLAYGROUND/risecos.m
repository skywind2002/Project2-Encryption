% 生成升余弦的形状
% f - 频点
% W - 带宽
% alpha - 滚降系数
function F = risecos(f, W, alpha)
    Ts = (1 + alpha) / (2 * W);
    L = W * (1 - alpha) / (1 + alpha); % [-L, L]内为常数 Ts
    Cos = @(f) cos(pi * Ts / alpha * (abs(f) - L));
    F = (abs(f) <= L) .* Ts + (L < abs(f) & abs(f) <= W) .* Ts/2 .* (1 + Cos(f));
end
