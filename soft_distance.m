%% 判断复数 z 与调制前行向量 y 的距离
% 需要将所要解的码放回到复平面再做
% WARNING: 这个函数只对作业二的情形（2ASK、实数信道）有效！
function d = soft_distance(z, y, p)
    d = sum((z - y).^2, 2);
end
