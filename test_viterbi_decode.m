clear,close,clc;

%% 课件上的例子
n = 3; k = 1; m = 4;
% 注意这里n=2的话就选QASK或者QPSK n=3的话就选8ASK或者8PSK 因为软解的话这两个值必须相同
A = cat(3, [1 1 1], [1 0 1], [0 1 1], [1 1 1]);
zero_begin = 1; % 从零状态开始
p = 2; % 有限域中的符号数 这里符号都是二元的
viterbi_mode = 0;

x = [1 1 0 0 1 1];

% 收尾
zero_end = 1;
y = conv_encode(x, n, k, m, A, zero_begin, zero_end, p);
% disp("y"); disp(y)

e = (rand(size(y)) < 0.5) * 0.23;
r = y + e;
decode = viterbi_decode(r, n, k, m, A, viterbi_mode, p);

disp("x"); disp(x);
disp("收尾"); disp(decode);
