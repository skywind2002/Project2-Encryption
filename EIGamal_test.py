import random
from EIGamal_get_param import EIGamal_get_param
from EIGamal_decode import EIGamal_decode
from EIGamal_encode import EIGamal_encode
import random

# EIGamal加解密联合调试,运行这个就能得到完整的加解密结果
p, g, y, d = EIGamal_get_param()
print("生成阶段p,g,y,d:", p, g, y, d)

message = random.randrange(2**250, 2**251)
c1, c2 = EIGamal_encode(message, y, p, g)
print("传输信息为(c1,c2):",c1,c2)
output = EIGamal_decode(c1, c2, d, p)
print("解码输出为output:",output)
print("最终误差为：",abs(message-output))
