function [secret] = DES_encode(message, SubKeyList, IP, IPInv, Ext, S, P)
    % DES加密程序，根据明文message和密钥生成的子密钥SubKeyList生成密文，剩下的都是需要的常数
    message1 = message(IP); %首先做IP置换
    L = message1(1:32);
    R = message1(33:64); %左右分开

    for i = 1:16 %迭代计算16次
        tmp = R;
        tmp = tmp(Ext); %32位扩展成48位
        tmp = xor(tmp, SubKeyList(i,:)); %与子密钥异或
        tmp1=zeros(1,32);
        for k = 1:8 %S变换,6位一组
            row = 2 * double(tmp((k-1) * 6 + 1)) + double(tmp((k-1) * 6 + 6)); %行数由高低两位指定
            column = 8 * double(tmp((k-1) * 6 + 2)) + 4 * double(tmp((k-1) * 6 + 3)) + 2 * double(tmp((k-1) * 6 + 4)) + double(tmp((k-1) * 6 + 5)); %列数由四位指定
            num = S(k,row * 16 + column+1); %从S盒中取出对应数字

            for j = 1:4
                tmp1(4*k+1-j) = (mod(num, 2));
                num = floor(num / 2); %将S盒中取出的数字2进制化存入
            end

        end

        %最终输出结果为32位
        tmp=tmp1;
        tmp = tmp(P); %P盒变换
        tmp = xor(tmp, L); %与左半边做异或
        L = R;
        R = tmp; %交换左右
    end
    
    message2=[R,L];  %组合左右两边
    secret=message2(IPInv);  %逆IP变化
end
