# 生成大素数程序，MATLAB用的不顺手，还是python好
# 素数判断采取算法：Miller-Rabin素性检验，可见https://www.cnblogs.com/philolif/p/prime-test.html
# main中生产两个大素数p,q(大小有GetPrime中的bitlen控制),然后依次生成n,phi和加解密密钥d,e
# 由于数字过大,谨慎起见采取文件操作

import random
import sys


def FastPow(base, power, n):
    # 快速幂函数，base为基，power为幂次，结果对n取模
    ans = 1
    tmp = base
    while power > 0:
        if power & 1 == 1:
            ans = (ans*tmp) % n
        tmp = (tmp*tmp) % n
        power = power >> 1
    return ans


def MillerRabinTest(n, iter_num=10):
    # 检测n是否为素数，检测iter_num次
    if n == 2:
        return True
    if n & 1 == 0 or n < 2:
        return False  # 特判
    m, s = n-1, 0
    while m & 1 == 0:
        m >>= 1
        s += 1  # 求出2的幂次以及剩下的奇数
    for _ in range(iter_num):
        b = FastPow(random.randint(2, n-1), m, n)  # 随机取数
        if b == 1 or b == n-1:
            continue
        for _ in range(s-1):
            b = FastPow(b, 2, n)
            if b == n-1:
                break
        else:
            return False
    return True


def PrimeTest(num):
    if num < 2:
        return False
    SmallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
                   233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499]  # 特判小素数,节省时间

    if num in SmallPrimes:
        return True
    for prime in SmallPrimes:
        if num % prime == 0:
            return False

    return MillerRabinTest(num)  # 实在看不出来了，还是Miller吧


def GetPrime(bitlen=1024):  # 生成一个比特串1024的比特串
    while True:
        num = random.randrange(2**(bitlen-1), 2**bitlen)
        if PrimeTest(num):
            return num  # 反复试验


def multi(filename1, filename2, filename3):
    # 文件高精度乘法,1*2=3
    # 因为生成的素数实在是太大了,还是用文件传输比较好
    file1 = open(filename1, "r")
    p = file1.read()
    p = str(p)
    file1.close()
    file2 = open(filename2, "r")
    q = file2.read()
    q = str(q)
    file2.close()
    a = [int(i) for i in p]
    b = [int(i) for i in q]  # 准备竖式
    c = [0 for i in range(len(a)+len(b))]
    a = a[::-1]  # 倒过来
    b = b[::-1]
    for i in range(len(b)):
        for j in range(len(a)):
            c[i+j] += a[j]*b[i]
            if (c[i+j] > 9):  # 进位
                c[i+j+1] += c[i+j]//10
                c[i+j] = c[i+j] % 10
    c = c[::-1]
    res = ""
    i = 0
    while c[i] == 0:
        i += 1  # 删除前导0
    for j in c[i:]:
        res += str(j)
    file3 = open(filename3, "w")
    file3.write(res)
    file3.close()

# 辗转相除法求gcd


def gcd(m, n):
    if m < n:
        return gcd(n, m)
    while n:
        m, n = n, m % n
    return m


def Gete(filename1, filename2):
    # 选择密钥e,filename1里面是欧拉函数phi,结果写入filename2
    file1 = open(filename1, "r")
    data = file1.read()
    file1.close()
    data = str(data)
    m = int(data)
    while True:
        n = random.randrange(2, 500000000000)
        if gcd(m, n) == 1:
            break
    file2 = open(filename2, "w")  # 结果写入
    file2.write(str(n))
    file2.close()


def Reuclid(m, n):
    if n == 0:
        return 1, 0, m
    x, y, q = Reuclid(n, m % n)
    x, y = y, (x-(m//n)*y)
    return x, y, q


def Getd(filename1, filename2, filename3):
    # 由密钥e和欧拉函数phi求
    file1 = open(filename1, "r")
    data1 = file1.read()
    data1 = str(data1)
    m = int(data1)
    file1.close()
    file2 = open(filename2, "r")
    data2 = file2.read()
    data2 = str(data2)
    n = int(data2)
    file2.close()
    a, b, c = Reuclid(m, n)  # 反辗转求e
    if a < 0:
        a += n
    file3 = open(filename3, "w")
    file3.write(str(a))
    file3.close()


def main():
    # 主程序，生成RSA所需要的两个大素数p和q
    p = GetPrime()
    file1 = open("RSA_p.txt", "w")
    file1.write(str(p))
    file1.close()
    file2 = open("RSA_p-1.txt", "w")
    file2.write(str(p-1))
    file2.close()
    q = GetPrime()
    file3 = open("RSA_q.txt", "w")
    file3.write(str(q))
    file3.close()
    file4 = open("RSA_q-1.txt", "w")
    file4.write(str(q-1))
    file4.close()
    multi("RSA_p-1.txt", "RSA_q-1.txt", "RSA_phi.txt")
    multi("RSA_p.txt", "RSA_q.txt", "RSA_n.txt")
    Gete("RSA_phi.txt", "RSA_e.txt")
    Getd("RSA_e.txt", "RSA_phi.txt", "RSA_d.txt")


if __name__ == "__main__":
    main()
