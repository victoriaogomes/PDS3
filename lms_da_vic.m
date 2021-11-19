%% un é a entrada de referência, algo parecido com o ruído real do sinal
%% w é o vetor que vai ser usado para armazenar os coeficientes do filtro
%% mu é o passo a ser utilizado para atualização dos coeficientes
function [normalized_yn, en, w, u] = lms_da_vic(dn, un, w, mu, u)
    %% Quantidade de coeficientes do filtro que será utilizado
    M = length(w);   

    %% Vetor inicialmente preenchido com zeros que vai armazenar os coeficientes atrasados
%     u = zeros(M, 1); 

    %% % Quantidade de iterações que serão realizadas
    iter = length(un);  

    %% % Vetor que vai armazenar a saída do filtro adaptativo, que é o que deve
    % ser subtraído da entrada primária:
    yn = zeros(1, iter); 

    %% Sinal efetivamente filtrado, é dado pela entrada primária menos o y(n)
    en = zeros(1, iter);
    for n = 1 : iter
        u = [un(n); u(1:end-1)];
        yn(n) = w' * u;
        normalized_dn = dn/max(abs(dn));
        normalized_yn = yn/max(abs(dn));
        en(n) = normalized_dn(n) - normalized_yn(n);
%         if n >= M
            w = w + (mu*en(n))*u;
%         end
    end
end