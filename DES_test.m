clear all;
clc;

% DES加密算法的测试程序，测试在无干扰情况下加解密是否正确
% 标准参考网址https://www.cnblogs.com/songwenlong/p/5944139.html

% DES的流程分为密钥生成和密文生成，在密文生成之前首先要做密钥生成
% 密钥生成步骤如下:根据指定的64bit密钥序列,通过KeyTable1减长为56bit,然后循环16次
% 生成16个密钥,每次生成的步骤中都包含"左右分离"->"移位"(由密钥index决定位数)->"组合"
% ,再对组合完成的比特序列用KeyTable2减长为48bit,从而得到16个子密钥

% 密文生成步骤如下:首先将密文做IP变换,然后左右分开,对右端进行操作.
% 操作步骤为:用Ext矩阵进行拓展32bit->48bit,然后与子密钥异或,然后利用S盒做S变换,
% (S变换是一个比较特殊的变换:将48bit分为8组,每组6bit的前后两位指示行数,中间4位指示列数,以此在相应的S盒中取出结果)
% 再利用P矩阵做P置换,最后与左端异或,交换左右两边的位置.
% 如是迭代16次,将R,L组合,再做IP逆置换即可得到密文
DES_get_param;  %生成DES加密所需要的参数
key=(randi([0,1],1,64)>0.5);
message=(randi([0,1],1,64)>0.5);
SubKeyList=DES_get_key(key,KeyTable1,KeyTable2);
secret=DES_encode(message,SubKeyList,IPTable,IPInvTable,Ext_Table,S,P_table);
message1=DES_decode(secret,SubKeyList,IPTable,IPInvTable,Ext_Table,S,P_table);
diff=(sum(message~=message1));  %这个值为0代表加密成功
fprintf("明文与解密密文汉明距离为:");
disp(diff);
