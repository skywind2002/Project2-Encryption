%% 判断复数 z 与调制前行向量 y 的距离
% 需要将所要解的码放回到复平面再做
% WARNING: 这个函数只对作业二的情形（MPSK、实数信道）有效！
% p 编码用到的总符号数 暂时没用
% M PSK的进制数
function d = soft_distance_PSK(z, y, p, M)
    % PSK
    r = 1;
    y_complex = r * exp(1j * (y * (2 * pi / M) + 2 * pi / (2 * M)));
    d = sum(abs(z - y_complex).^2, 2);

    % 2ASK
    % d = sum((z - y).^2, 2);

end

%% example
% 8PSK:
% z = exp(1j*2*pi/8*1.1)
% y = [0,0,0]
% mapping8(y) = exp(1j*2*pi/8*0)
% 然后就可以计算他们的均方距离了
