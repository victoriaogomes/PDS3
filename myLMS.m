function [e, y, w, xx] = myLMS(d, x, mu, M, w1)

Ns = length(d);
if (Ns <= M)  
    print('error');
    return; 
end
if (Ns ~= length(x))  
    print('error');
    return; 
end

% xx = zeros(Ns, 1);
% y = zeros(Ns,1);
% e = zeros(Ns,1);
% %% Cálculo dos sinal de entrada atrasado
% for n = 1:Ns
%     xx = [xx(2:M);x(n)];
%     y(n) = w1' * xx;        % Ruído a ser removido
%     e(n) = d(n) - y(n);
% end

%% Checagem de SNR
snrval = mySNR(d, x);
if snrval < 0
    snrval = snrval*(-1);
end
fprintf('O SNR DA ENTRADA É: %.3f \n', snrval)
% if snrval < 25
%     disp('atualizei peso');
    y = zeros(Ns,1);
    e = zeros(Ns,1);
    xx = zeros(Ns, 1);
    for n = 1:Ns
        xx = [xx(2:M);x(n)];
        y(n) = w1' * xx;
        normalized_dn = d/max(abs(d));
        normalized_yn = y/max(abs(d));
        e(n) = normalized_dn(n) - normalized_yn(n);
        w1 = w1 + mu * e(n) * xx;   
        w = w1;
    end
% end
% w = w1;
snrval = mySNR(e, x);
if snrval < 0
    snrval = snrval*(-1);
end
fprintf('O SNR DA SAÍDA É: %.3f \n', snrval)
end