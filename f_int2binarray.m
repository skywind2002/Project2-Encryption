% f_int2binarray([1,3,5],3)
% ans =
%      0     0     1     0     1     1     1     0     1
function result = f_int2binarray(input, len)
    result = dec2bin(input, len) - '0';
    result = result';
    result = result(:)';
end
