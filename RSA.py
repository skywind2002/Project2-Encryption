# -*- coding: utf-8 -*-  

"""
功能：生成 RSA 秘钥、利用秘钥对明文进行加密和解密。
使用方法：python RSA.py G/E/D [<len>/PU/PR]
    G: 生成秘钥。E：加密。D：解密。<len>：消息的二进制长度。PU：使用公钥。PR：使用私钥
例：
    - python RSA.py G 1024（生成 1024 位秘钥，保存在 ./data/RSA_pub.txt ./data/RSA_pri.txt 中）
    - python RSA.py E PU（利用公钥对 ./data/message.txt 中的二进制信息加密，以二进制输出到 ./data/secret.txt 中）
    - python RSA.py D PR（利用私钥对 ./data/secret.txt 中的二进制信息解密，以二进制输出到 ./data/message.txt 中）
在 MATLAB 中使用方式：
    system("python RSA.py G 1024"); % 生成秘钥，这一步可以不做
    % 加密
    f = fopen('./data/message.txt','w');
    fwrite(f, char(message + '0')); % 将行向量比特流 message 写入明文文件
    fclose(f);
    system("python RSA.py E PU"); % 用公钥加密
    f = fopen('./data/secret.txt','r');
    secret = fread(f) - '0'; % 从密文文件读回加密比特流
    fclose(f);
    % 解密
    f = fopen('./data/secret.txt','w');
    fwrite(f, char(secret + '0')); % 将行向量比特流 secret 写入密文文件
    fclose(f);
    system("python RSA.py D PR"); % 用私钥解密
    f = fopen('./data/message.txt','r');
    message = fread(f) - '0'; % 从明文文件读回解密比特流
    fclose(f);
"""

import random
import sys
from GetPrime import GetPrime, FastPow, Reuclid

# 辗转相除法求gcd


def gcd(m, n):
    if m < n:
        return gcd(n, m)
    while n:
        m, n = n, m % n
    return m

# 生成和 phi 互素的公钥 e，e << phi


def Gete(phi, p, q):
    e = max(p, q)
    while True:
        e = e+2  # e取为大于p和q的数即可，没必要搞得那么大
        if gcd(phi, e) == 1:
            break
    return e

# 由密钥 e 和欧拉函数 phi 求私钥 d


def Getd(phi, e):
    d, _, _ = Reuclid(e, phi)  # 反辗转求 d
    if d < 0:
        d += phi
    return d


if __name__ == "__main__":
    if(sys.argv[1] == "G"):  # 生成一对秘钥
        bitlen = int(sys.argv[2])
        p = GetPrime(bitlen / 2)  # 生成 RSA 所需要的两个大素数 p 和 q
        q = GetPrime(bitlen - bitlen / 2)
        while(len(bin(p * q)[2:]) != bitlen):
            q = q = GetPrime(bitlen - bitlen / 2)
        phi = (p - 1) * (q - 1)
        n = p * q
        e = Gete(phi, p, q)  # 生成公钥
        d = Getd(phi, e)  # 生成私钥
        with open("./data/RSA_pub.txt", "w") as f:
            f.write(str(e))
            f.write("\n")
            f.write(str(n))
        with open("./data/RSA_pri.txt", "w") as f:
            f.write(str(d))
            f.write("\n")
            f.write(str(n))

    elif(sys.argv[1] == "E"):  # 编码
        # 读入明文
        with open("./data/message.txt", "r") as f:
            m = int(f.read(), 2)
        # 读入秘钥
        file = "./data/RSA_pub.txt" if (sys.argv[2]
                                        == "PU") else "./data/RSA_pri.txt"
        with open(file, "r") as f:
            key = int(f.readline())
            n = int(f.readline())
        # 输出密文
        with open("./data/secret.txt", "w") as f:
            s = FastPow(m, key, n)
            s_bin = bin(s)[2:]
            s_bin = "0" * (len(bin(n)[2:]) - len(s_bin)) + s_bin  # 前面补零
            f.writelines(s_bin)

    elif(sys.argv[1] == "D"):  # 解码
        # 读入密文
        with open("./data/secret.txt", "r") as f:
            s = int(f.read(), 2)
        # 读入秘钥
        file = "./data/RSA_pub.txt" if (sys.argv[2]
                                        == "PU") else "./data/RSA_pri.txt"
        with open(file, "r") as f:
            key = int(f.readline())
            n = int(f.readline())
        # 输出明文
        with open("./data/message.txt", "w") as f:
            m = FastPow(s, key, n)
            m_bin = bin(m)[2:]
            m_bin = "0" * (len(bin(n)[2:]) - len(m_bin)) + m_bin  # 前面补零
            f.writelines(m_bin)
