function [SubkeyList] = DES_get_key(key, KeyTable1, KeyTable2)
    % 由64位密钥生成16个48位子密钥的方法
    SubkeyList = zeros(16, 48); %每行就是一个子密钥
    key0 = key(KeyTable1);     %源密钥经过KeyTable1变换的结果

    %进行16次循环生成16个密钥
    for i = 1:16
        temp1 = key0(1:28);
        temp2 = key0(29:56); %将key0分成左右两个部分

        if (i == 1 || i == 2 || i == 9 || i == 16)
            temp1 = [temp1(2:end), temp1(1)];
            temp2 = [temp2(2:end), temp2(1)]; %循环移位1位
        else
            temp1 = [temp1(3:end), temp1(1:2)];
            temp2 = [temp2(3:end), temp2(1:2)]; %循环移位2位
        end

        key0 = [temp1, temp2]; %再度组合

        key1=key0(KeyTable2);

        SubkeyList(i, :) = key1; %填入当前密钥
    end

end
