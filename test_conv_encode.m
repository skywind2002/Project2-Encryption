clear,close,clc;

%% 课件上的例子
n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
zero_begin = 1; % 从零状态开始
p = 2; % 有限域中的符号数 这里符号都是二元的

x = [1 1 0];

% 不收尾
zero_end = 0;
y = conv_encode(x, n, k, m, A, zero_begin, zero_end, p);
disp(y) % 应该是 11 10 10

% 收尾
zero_end = 1;
x = [1 1 0];
y = conv_encode(x, n, k, m, A, zero_begin, zero_end, p);
disp(y) % 应该是 11 10 10 11 00
