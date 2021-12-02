classdef RLSModel < handle
    % Classe responsável pela aplicação do método RLS
    properties
        filtOrd = 25;                       % Ordem do filtro
        lambda = 1;                     % Fator de esquecimento
        filtWeights;                        % Array de pesos do filtro
        delayedCoeffs;                      % Sinal de referêcia atrasado 
        signalInputSNR;                     % SNR do sinal de entrada
        signalOutputSNR;                    % SNR do sinal de saída
        estimatedNoise;                     % Ruído estimado
        filteredSignal;                     % Sinal filtrado
        p;                                  % Matriz de autocorrelação
        elapsedTime;                        % Tempo que levou para filtrar o último sinal informado
    end
    
    methods
        function obj = RLSModel()
            % Constrói uma instância dessa classe
        end
        
        % Função que inicializa as propriedades do modelo para filtrar um sinal
        function obj = initModel(obj, iterQntd, audioSignalSize)
            obj.filtWeights = zeros(obj.filtOrd, 1);
            obj.filteredSignal = zeros(audioSignalSize, 1);
            obj.estimatedNoise = zeros(audioSignalSize, 1);
            obj.delayedCoeffs = zeros(obj.filtOrd, 1);
            obj.signalInputSNR = zeros(iterQntd, 1);
            obj.signalOutputSNR = zeros(iterQntd, 1);
            I = eye(obj.filtOrd);
            a = 0.001;
            obj.p = (a^(-1)) * I;
        end
        
        % Função para pegar um fragmento do áudio recebido por parâmetro,
        % indo da posição startSample até a posição endSample
        function filterSignal(obj, primSignal, refSignal, auxiliarFunctions)
            % Quantidade de iterações necessárias para filtrar todo o sinal
            iterQntd = auxiliarFunctions.getIterSize(primSignal);
            
            % Inicializa as variáveis necessárias do modelo para executar o RLS
            obj.initModel(iterQntd, length(primSignal));
            
            % Comando iniciar a contabilização o tempo de execução do RLS
            tic
            
            for i = 1 : iterQntd
                % Atualizando informações para carregamento de partes do
                % áudio
                auxiliarFunctions.updateSamplesVariables(i);
                
                % Pega parte do áudio que será filtrada nessa iteração
                audioPart = auxiliarFunctions.getAudioPart(primSignal);
                
                % Pega a parte do ruído que será utilizada para estimar o
                % ruído real presente no sinal
                noisePart = auxiliarFunctions.getAudioPart(refSignal);
                
                % Filtragem efetiva da parte do sinal selecionada
                [estimatedNoisePart, filtSignalPart] = obj.filterSignalPart(audioPart, noisePart);
                
                % Salvando para compor o sinal filtrado completo
                obj.filteredSignal(auxiliarFunctions.startSample:auxiliarFunctions.endSample) = filtSignalPart;
                
                % Salvando para compor o ru´dio estimado completo
                obj.estimatedNoise(auxiliarFunctions.startSample:auxiliarFunctions.endSample) = estimatedNoisePart;
                
                % Cálculo do SNR da entrada do sinal filtrado nessa
                % iteração
                obj.signalInputSNR(i) = auxiliarFunctions.mySNR(audioPart, noisePart);
                
                % Cálculo do SNR da saída do sinal filtrado nessa
                % iteração
                obj.signalOutputSNR(i) = auxiliarFunctions.mySNR(filtSignalPart, estimatedNoisePart);
            end
            % Comando finalizar a contabilização o tempo de execução do RLS
            obj.elapsedTime = toc;
        end
        
        
        % Filtra o sinal primSignal recebido por parâmetro, usando o refSignal para estimar 
        % o ruído que deve ser removido
        function [estimNoise, norm_filtSignal] = filterSignalPart(obj, primSignal, refSignal)
            % Quantidade de iterações que serão realizadas
            iter = length(primSignal);
            
            % Vetor que vai armazenar a saída do filtro adaptativo, que é o que deve
            % ser subtraído da entrada primária:
            estimNoise = zeros(iter, 1); 
            
            % Sinal efetivamente filtrado, é dado pela entrada primária menos o estimNoise
            filtSignal = zeros(iter, 1);
            
            % Aplicação do RLS e filtragem do sinal
            for n = 1:iter
                obj.delayedCoeffs = [refSignal(n); obj.delayedCoeffs(1:obj.filtOrd-1)];
                k = (obj.p * obj.delayedCoeffs) ./ (obj.lambda + obj.delayedCoeffs' * obj.p * obj.delayedCoeffs);
                
                filtSignal(n) = obj.delayedCoeffs'*obj.filtWeights;
                
                norm_primSignal = primSignal/max(abs(primSignal));
                norm_filtSignal = filtSignal/max(abs(primSignal));
                estimNoise(n) = norm_primSignal(n) - norm_filtSignal(n);
                
                
                obj.filtWeights = obj.filtWeights + k * conj(estimNoise(n));
                obj.p = (obj.p - k * obj.delayedCoeffs' * obj.p) ./ obj.lambda;
            end
        end
    end
end

