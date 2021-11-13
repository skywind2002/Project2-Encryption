import random
import sys

# 快速幂函数，base 为基，power 为幂次，结果对 n 取模


def FastPow(base, power, n):
    base = base % n
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

    SmallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
                   233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499]  # 特判小素数,节省时间

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
# 扩展欧几里得算法，在求得gcd的同时表明其系数


def Reuclid(m, n):
    if n == 0:
        return 1, 0, m
    x, y, q = Reuclid(n, m % n)
    x, y = y, (x-(m//n)*y)
    return x, y, q
