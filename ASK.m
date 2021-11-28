% message 原信息比特序列
% M 传输的进制数 2/4/8/16
% a_n 要发送的符号序列
% 注意使用Gray码映射
function a_n = ASK(message, M)
    assert(mod(length(message), log2(M)) == 0, "[ASK] message长度不对");

    switch log2(M)
        case 1
            % BASK 直接返回原序列就好了
            % 相当于 0映射到低电平0 1映射到高电平1
            a_n = message;
        case 2
            % QASK 注意Gray码 00-0 01-1 11-2 10-3
            gray_code_4 = [0, 1, 3, 2];
            int_n = message(1:log2(M):end) * 2 + message(2:log2(M):end) * 1;
            a_n = gray_code_4(int_n + 1);
        case 3
            % 8ASK 注意Gray码 000-0 001-1 011-2 010-3 110-4 111-5 101-6 100-7
            gray_code_8 = [0, 1, 3, 2, 7, 6, 4, 5];
            int_n = message(1:log2(M):end) * 4 + message(2:log2(M):end) * 2 + message(3:log2(M):end) * 1;
            a_n = gray_code_8(int_n + 1);
        case 4
            % 16ASK 注意Gray码
            % 0000-0 0001-1 0011-2 0010-3 0110-4 0111-5 0101-6 0100-7
            % 1100-8 1101-9 1111-10 1110-11 1010-12 1011-13 1001-14 1000-15
            gray_code_16 = [0, 1, 3, 2, 7, 6, 4, 5, 15, 14, 12, 13, 8, 9, 11, 10];
            int_n = message(1:log2(M):end) * 8 + message(2:log2(M):end) * 4 + message(3:log2(M):end) * 2 + message(4:log2(M):end) * 1;
            a_n = gray_code_16(int_n + 1);
        otherwise
            assert(0, "没有相应的ASK映射方式")
    end

end

%% test
% ASK([0 1 1 0 1 1], 2) % 0     1     1     0     1     1
% ASK([0 1 1 0 1 1], 4) % 1     3     2
% ASK([0 1 1 0 1 1 1 1 0 1 0 0], 8) % 2     2     4     7
% ASK([0 1 1 0 1 1 1 1 0 1 0 0], 16) % 4    10     7
