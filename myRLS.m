function [e, y, w, xx, p] = myRLS(d, x, lambda, M, w1, p, xx)

Ns = length(d);
if (Ns <= M)  
    print('error');
    return; 
end
if (Ns ~= length(x))  
    print('error');
    return; 
end

y = zeros(Ns, 1);
e = zeros(Ns, 1);
% xx = zeros(M,1);

for n = 1:Ns
    xx = [x(n); xx(1:M-1)];
    k = (p * xx) ./ (lambda + xx' * p * xx);
    y(n) = xx'*w1;
    normalized_dn = d/max(abs(d));
    normalized_yn = y/max(abs(d));
    e(n) = normalized_dn(n) - normalized_yn(n);
    w1 = w1 + k * e(n);
    p = (p - k * xx' * p) ./ lambda;
    w = w1;
end

end