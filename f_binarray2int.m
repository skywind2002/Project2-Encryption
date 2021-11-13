% f_binarray2int([1 1 0])
% ans =
%      6
function result = f_binarray2int(input)
    result = bin2dec(char(input + '0'));
end
