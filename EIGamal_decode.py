from GetPrime import FastPow, Reuclid

# EIGamal解密算法,知道的信息有传输过来的信号c1,c2以及私钥d,公钥p,g
# 需要先在EIGamal_test中运行参数生成和加密作为先导
def EIGamal_decode(input1, input2, d, p):
    V = FastPow(input1, d, p)  # 此时V=g^(dk)，利用私钥d将加密端的k破译
    InvV, _, _ = Reuclid(V, p)
    if InvV < 0:
        InvV += p  # 利用扩展欧几里得算法求V的逆，保证InvV非负
    output = (input2*InvV) % p  # 最终输出就是c2*V^(-1)
    print("解密阶段：V,InvV,output", V, InvV, output)
    return output
