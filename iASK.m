% y_n 接收到的波形采样之后的浮点值
% M 映射方式的进制数 2/4/8/16
% message_rec 恢复的信息 使用门限进行判决即可
function message_rec = iASK(y_n, M)

    A = 1/2; % 分层的电平 方便下面直接写A的倍数

    switch log2(M)
        case 1
            message_rec = (y_n > 0.5);
        case 2
            % QASK 注意Gray码 00-0 01-1 11-2 10-3
            % gray_code_4 = [0, 1, 3, 2];
            igray_code_4 = [0, 1, 3, 2];
            int_rec = ((y_n >= 1 * A) + (y_n >= 3 * A) + (y_n >= 5 * A)) * 1;
            int_rec = igray_code_4(int_rec + 1);
            message_rec = f_int2binarray(int_rec, 2);
        case 3
            % 8ASK 注意Gray码 000-0 001-1 011-2 010-3 110-4 111-5 101-6 100-7
            % gray_code_8 = [0, 1, 3, 2, 7, 6, 4, 5];
            igray_code_8 = [0, 1, 3, 2, 6, 7, 5, 4];
            int_rec = ((y_n >= 1 * A) + (y_n >= 3 * A) + (y_n >= 5 * A) + (y_n >= 7 * A) + (y_n >= 9 * A) + (y_n >= 11 * A) + (y_n >= 13 * A)) * 1;
            int_rec = igray_code_8(int_rec + 1);
            message_rec = f_int2binarray(int_rec, 3);
        case 4
            % 16ASK 注意Gray码
            % 0000-0 0001-1 0011-2 0010-3 0110-4 0111-5 0101-6 0100-7
            % 1100-8 1101-9 1111-10 1110-11 1010-12 1011-13 1001-14 1000-15
            % gray_code_16 = [0, 1, 3, 2, 7, 6, 4, 5, 15, 14, 12, 13, 8, 9, 11, 10];
            igray_code_16 = [0, 1, 3, 2, 6, 7, 5, 4, 12, 13, 15, 14, 10, 11, 9, 8];
            int_rec = ((y_n >= 1 * A) + (y_n >= 3 * A) + (y_n >= 5 * A) + (y_n >= 7 * A) + (y_n >= 9 * A) + (y_n >= 11 * A) + (y_n >= 13 * A) + (y_n >= 15 * A) + (y_n >= 17 * A) + (y_n >= 19 * A) + (y_n >= 21 * A) + (y_n >= 23 * A) + (y_n >= 25 * A) + (y_n >= 27 * A) + (y_n >= 29 * A)) * 1;
            int_rec = igray_code_16(int_rec + 1);
            message_rec = f_int2binarray(int_rec, 4);
        otherwise
            assert(0, "没有相应的iASK映射方式")
    end

end

%% test
% ASK([0 1 1 0 1 1], 2) % 0     1     1     0     1     1
% iASK([0 1 1 0 1 1], 2) % 0   1   1   0   1   1
% ASK([0 1 1 0 1 1], 4) % 1     3     2
% iASK([1 3 2], 4) % 0     1     1     0     1     1
% ASK([0 1 1 0 1 1 1 1 0 1 0 0], 8) % 2     2     4     7
% iASK([2 2 4 7], 8) % 0     1     1     0     1     1     1     1     0     1     0     0
% ASK([0 1 1 0 1 1 1 1 0 1 0 0], 16) % 4    10     7
% iASK([4 10 7], 16) % 0     1     1     1     1     1     0     0     0     1     0     1
