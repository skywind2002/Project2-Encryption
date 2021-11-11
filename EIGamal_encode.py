
import random
from GetPrime import FastPow

# EIGamal的加密程序，需要先在EIGamal_test.py中生成参数作为输入
def EIGamal_encode(input, y, p, g):
    # 生成加密的参数k
    k = random.randrange(2, p-2)
    # 进行加密
    U = FastPow(y, k, p)  # 此时U=g^(dk)
    c1 = FastPow(g, k, p)   # c1是参照项,c1=g^k,向解码器传输k的信息
    c2 = (U*input) % p  # c2是真正承载信息的项，其值为g^(dk)*input

    # 最终(c1,c2)就是传输出去的信息
    print("加密阶段k,U,c1,c2,input:", k, U, c1, c2, input)
    return c1, c2
