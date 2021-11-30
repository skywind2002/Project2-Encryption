% 判断实际的行向量 a 与理想的行向量 b 的距离
function d = hard_distance(a, b, p)
    % d = mod(a - b, p);
    d = sum(a ~= b, 2);
end
