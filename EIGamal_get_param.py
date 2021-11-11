from os import defpath
from GetPrime import GetPrime, FastPow, PrimeTest
import random
import sys

# 本程序用于生成EIGamal加密算法所需要的公钥与私钥
# 这只是个函数，测试的话运行EIGamal_test.py

# 公钥部分有:
# p: 大质数, 是循环域的大小
# g: 循环域GF(p)内的生成元，满足g的1~p-1次幂遍历1~p-1
# y:生成元的私钥次幂,由于循环域上的对数求解是困难的,所以截获y和g的Eve并不能获取私钥d

# 私钥部分有:
# d：2~p-1的一个随机整数
def EIGamal_get_param(p=9):  # 参数为p的初始值，是啥都行，别是素数
    # 找到生成域的素数p
    while PrimeTest(p) == 0:
        q = GetPrime(256)
        p = 2*q+1  # 随便加点要求，比如p-1有大素因子
    g = random.randrange(2, p-1)  # 由于p是素数，生成元g随便取一个就行了
    d = random.randrange(2, p-1)  # 私钥d
    y = FastPow(g, d, p)  # 公开
    return p, g, y, d
