% SK_QASK([0 1 1 0 1 1])
% ans =
%     1   2   3
function a_n = SK_QASK(message)
    a_n = message(1:2:end) * 2 + message(2:2:end) * 1;
end
