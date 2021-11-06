function [] = RSA_get_param()
    % 生成RSA算法的各种参数:大参数pq,乘积n，欧拉函数phi,加解密密钥d与e
    command = 'python RSA_get_param.py';
    status=system(command)
end
