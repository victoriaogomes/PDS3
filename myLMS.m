function [e, y, w, u] = myLMS(dn, un, mu, M, w)

    %% Definição do número de iterações que serão executadas no loop
    iter = length(dn);
    
    %% Validação dos parâmetros recebidos
    if (iter <= M)  
        error('Não é possível processar um sinal com a quantidade de amostras menor que a ordem do filtro utilizado.');
    end
    if (iter ~= length(un))  
        error('Não é possível processar um sinal utilizando uma entrada de referência ' ...
            + 'com uma quantidade diferente de amostras.'); 
    end
    
    %% Inicialização dos vetores que serão utilizados no cálculo do LMS
    y = zeros(length(dn),1);
    e = zeros(length(dn),1);
    u = zeros(length(dn), 1);
    
    %% Laço de repetição para a filtragem adaptativa
    for n = 1:iter
        u = [u(2:M);un(n)];
        y(n) = w' * u;
        e(n) = dn(n) - y(n);
        if n >= M
            w = w + mu * e(n) * u;
        end
    end

end