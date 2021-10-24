function [e, y, w, xx] = myLMSFelipe(d, x, mu, M, w1)

Ns = length(d);
if (Ns <= M)  
    print('error');
    return; 
end
if (Ns ~= length(x))  
    print('error');
    return; 
end

y = zeros(Ns,1);
e = zeros(Ns,1);
xx = zeros(Ns, 1);

for n = 1:Ns
    xx = [xx(2:M);x(n)];
    y(n) = w1' * xx;
    e(n) = d(n) - y(n);
    w1 = w1 + mu * e(n) * xx;
    w = w1;
end

end