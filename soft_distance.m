%% 判断复数 z 与调制前行向量 y 的距离
% 需要将所要解的码放回到复平面再做
function d = soft_distance(z, y, mapping, p)
    b = base2dec(char(y + '0'), p) + 1;
    m = mapping(b).';
    dis = log(abs(m - z) + 1); % QUESTION: PSK的话这里是不是只计算角度的相对差就可以了？
    d = sum(dis, 2);
end
