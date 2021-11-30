clear,close,clc;

%% 课件上的例子
n = 2; k = 1; m = 3;
A = cat(3, [1 1], [0 1], [1 1]); % A_2 ~ A_0的拼接 A2=[1 1] A1=[0 1] A0=[1 1]
zero_begin = 1; % 从零状态开始
p = 2; % 有限域中的符号数 这里符号都是二元的
viterbi_mode = 0; % ERROR: mode=1 soft viterbi

x = [1 1 0 0 1 1 0 1 1 1 0 1];
disp(x)

% 不收尾
zero_end = 0;
y = conv_encode(x, n, k, m, A, zero_begin, zero_end, p);
% disp(y) % 11 10 10

% e = rand(size(r)) < 0.1
% r = r + e;
r = y;
decode = viterbi_decode(r, n, k, m, A, viterbi_mode, p);
disp(decode) % ERROR: [1 0 0] 应该是 [1 1 0]

% 收尾
zero_end = 1;
y = conv_encode(x, n, k, m, A, zero_begin, zero_end, p);
% disp(y) % 11 10 10 11 00

% e = rand(size(r)) < 0.1;
% r = r + e;
r = y;
decode = viterbi_decode(r, n, k, m, A, viterbi_mode, p);
disp(decode)
