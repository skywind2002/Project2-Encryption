% SKi_QASK([-1,0.5,1,1.9,3,10])
% ans =
%      0     0     0     1     0     1     1     0     1     1     1     1
function message_rec = SKi_QASK(y_n)
    A = 1/2;
    message_rec = ((y_n >= 1 * A) + (y_n >= 3 * A) + (y_n >= 5 * A)) * 1;
    message_rec = f_int2binarray(message_rec, 2);
end
