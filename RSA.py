"""
功能：生成 RSA 秘钥、利用秘钥对明文进行加密和解密。
使用方法：python RSA.py G/E/D [PU/PR]
    G: 生成秘钥。E：加密。D：解密。PU：使用公钥。PR：使用私钥
例：
    - python RSA.py G（生成秘钥，保存在 ./data/RSA_pub.txt ./data/RSA_pri.txt 中）
    - python RSA.py E PU（利用公钥对 ./data/message.txt 中的二进制信息加密，以二进制输出到 ./data/secret.txt 中）
    - python RSA.py D PR（利用私钥对 ./data/secret.txt 中的二进制信息解密，以二进制输出到 ./data/message.txt 中）
在 MATLAB 中使用方式：
    system("python RSA.py G"); % 生成秘钥，这一步可以不做
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

# 快速幂函数，base 为基，power 为幂次，结果对 n 取模
def FastPow(base, power, n):
    ans = 1
    tmp = base
    while power > 0:
        if power & 1 == 1:
            ans = (ans*tmp) % n
        tmp = (tmp*tmp) % n
        power = power >> 1
    return ans

# Miller-Rabin 素性检验，可见 https://www.cnblogs.com/philolif/p/prime-test.html
# 检测 n 是否为素数，检测 iter_num 次
def MillerRabinTest(n, iter_num=10):
    if n == 2:
        return True
    if n & 1 == 0 or n < 2:
        return False  # 特判
    m, s = n-1, 0
    while m & 1 == 0:
        m >>= 1
        s += 1  # 求出2的幂次以及剩下的奇数, n = m * 2^s + 1, m 为奇数
    for _ in range(iter_num):
        b = FastPow(random.randint(2, n-1), m, n)  # 随机取数
        if b == 1 or b == n-1:
            continue
        for __ in range(s-1):
            b = FastPow(b, 2, n)
            if b == n-1:
                break
        else:
            return False
    return True


def PrimeTest(num):
    if num < 2:
        return False
    
    SmallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499]  # 特判小素数,节省时间

    if num in SmallPrimes:
        return True
    for prime in SmallPrimes:
        if num % prime == 0:
            return False
    return MillerRabinTest(num)  # 实在看不出来了，还是Miller吧


# 生成一个指定长度的首一随机比特串
def GetPrime(bitlen=1024):  
    while True:
        num = random.randrange(2**(bitlen-1), 2**bitlen)
        if PrimeTest(num):
            return num  # 反复试验

# 辗转相除法求gcd
def gcd(m, n):
    if m < n:
        return gcd(n, m)
    while n:
        m, n = n, m % n
    return m

# 生成和 phi 互素的公钥 e，e << phi
def Gete(phi):
    while True:
        e = random.randrange(2, 500000000000)
        if gcd(phi, e) == 1:
            break
    return e

# 寻找 x 使得 (x * m) mod n = 1
def Reuclid(m, n):
    if n == 0:
        return 1, 0, m
    x, y, q = Reuclid(n, m % n)
    x, y = y, (x-(m//n)*y)
    return x, y, q

# 由密钥 e 和欧拉函数 phi 求私钥 d
def Getd(phi, e):
    d, _, _ = Reuclid(e, phi)  # 反辗转求 d
    if d < 0:
        d += phi
    return d

if __name__ == "__main__":
    if(sys.argv[1] == "G"): # 生成一对秘钥
        p = GetPrime() # 生成 RSA 所需要的两个大素数 p 和 q
        q = GetPrime()
        phi = (p - 1) * (q - 1)
        n = p * q
        e = Gete(phi) # 生成公钥
        d = Getd(phi, e) # 生成私钥
        with open("./data/RSA_pub.txt", "w") as f:
            f.write(str(e))
            f.write("\n")
            f.write(str(n))
        with open("./data/RSA_pri.txt", "w") as f:
            f.write(str(d))
            f.write("\n")
            f.write(str(n))
    
    elif(sys.argv[1] == "E"): # 编码
        # 读入明文
        with open("./data/message.txt", "r") as f:
            m = int(f.read(), 2)
        # 读入秘钥
        file = "./data/RSA_pub.txt" if (sys.argv[2] == "PU") else "./data/RSA_pri.txt"
        with open(file, "r") as f:
            key = int(f.readline())
            n = int(f.readline())
        # 输出密文
        with open("./data/secret.txt", "w") as f:
            s = FastPow(m, key, n)
            f.writelines(bin(s)[2:])

    elif(sys.argv[1] == "D"): # 解码
        # 读入密文
        with open("./data/secret.txt", "r") as f:
            s = int(f.read(), 2)
        # 读入秘钥
        file = "./data/RSA_pub.txt" if (sys.argv[2] == "PU") else "./data/RSA_pri.txt"
        with open(file, "r") as f:
            key = int(f.readline())
            n = int(f.readline())
        # 输出明文
        with open("./data/message.txt", "w") as f:
            m = FastPow(s, key, n)
            f.writelines(bin(m)[2:])