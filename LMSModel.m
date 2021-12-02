classdef LMSModel < handle
    % Classe responsável pela aplicação do método LMS
    properties
        filtOrd = 25;                       % Ordem do filtro
        filtWeights;                        % Array de pesos do filtro
        stepSize = 0.001;                   % Tamanho do passo utilizado no LMS
        delayedCoeffs;                      % Sinal de referêcia atrasado 
        signalInputSNR;                     % SNR do sinal de entrada
        signalOutputSNR;                    % SNR do sinal de saída
        estimatedNoise;                     % Ruído estimado
        filteredSignal;                     % Sinal filtrado
        elapsedTime;                        % Tempo que levou para filtrar o último sinal informado
    end
    
    methods
        % Função que cria uma instância dessa classe
        function obj = LMSModel()
        end
        
        % Função que inicializa as propriedades do modelo para filtrar um sinal
        function initModel(obj, iterQntd, audioSignalSize)
            obj.filtWeights = ones(obj.filtOrd, 1).*0.3;
            obj.filteredSignal = zeros(audioSignalSize, 1);
            obj.estimatedNoise = zeros(audioSignalSize, 1);
            obj.delayedCoeffs = zeros(obj.filtOrd, 1);
            obj.signalInputSNR = zeros(iterQntd, 1);
            obj.signalOutputSNR = zeros(iterQntd, 1);
        end
        
        % Função que filtra o sinal recebido por parâmetro, segmentando-o
        % de acordo com o indicado pela classe auxiliarFunctions
        function filterSignal(obj, primSignal, refSignal, auxiliarFunctions)
            % Quantidade de iterações necessárias para filtrar todo o sinal
            iterQntd = auxiliarFunctions.getIterSize(primSignal);
            
            % Inicializa as variáveis necessárias do modelo para executar o LMS
            obj.initModel(iterQntd, length(primSignal));
            
            % Comando iniciar a contabilização o tempo de execução do LMS
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
            % Comando finalizar a contabilização o tempo de execução do LMS
            obj.elapsedTime = toc;
        end
        
        
        % Filtra o sinal primSignal recebido por parâmetro, usando o refSignal para estimar 
        % o ruído que deve ser removido
        function [estimNoise, normFiltSignal] = filterSignalPart(obj, primSignal, refSignal)
            % Quantidade de iterações que serão realizadas
            iter = length(refSignal);
            
            % Vetor que vai armazenar a saída do filtro adaptativo, que é o
            % sinal já filtrado
            filtSignal = zeros(iter, 1); 
            
            % Vetor que vai armazenar o ruído estimado a cada iteração do
            % método LMS
            estimNoise = zeros(iter, 1);

            % Aplicação do LMS e filtragem do sinal
            for n = 1 : iter
                obj.delayedCoeffs = [refSignal(n); obj.delayedCoeffs(1:end-1)];
                
                % Passo 1: Filtragem
                filtSignal(n) = obj.filtWeights' * obj.delayedCoeffs;
                
                % Passo 2: Estimação do erro
                normPrimSignal = primSignal/max(abs(primSignal));
                normFiltSignal = filtSignal/max(abs(primSignal));
                estimNoise(n) = normPrimSignal(n) - normFiltSignal(n);
                
                % Passo 3: Adaptação do array de pesos do filtro
                obj.filtWeights = obj.filtWeights + ...
                    (obj.stepSize*estimNoise(n))*obj.delayedCoeffs;
            end
        end
    end
end

