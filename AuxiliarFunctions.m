classdef AuxiliarFunctions < handle
    % Classe utilizada para fornecer métodos auxiliares tanto para a
    % filtragem usando LMS quanto para RLS
    properties
        startSample = 1;        % Amostra onde a filtragem vai iniciar
        endSample = 1000;       % Amostra onde a filtragem vão finalizar
        maxSampleQntd = 1000;   % Quantidade de amostras filtradas por execução
        fs = 8000;              % Frequência de amostragem para gravação de áudio
    end
    
    methods
        % Função que cria uma instância dessa classe
        function obj = AuxiliarFunctions()
        end
        
        % Função que atualiza a amostra inicial e a final para uma nova iteração
        function obj = updateSamplesVariables(obj, iterStep)
            obj.startSample = (iterStep-1)*obj.maxSampleQntd + 1;
            obj.endSample = obj.startSample + obj.maxSampleQntd - 1;
        end
        
        % Função para pegar um fragmento do áudio recebido por parâmetro,
        % indo da posição startSample até a posição endSample
        function s = getAudioPart(obj, audio)
            if obj.startSample > length(audio)
                error('Foi solicitada a leitura de um intervalo do sinal começando por uma amostra de número' ...
                     +' maior do que a quantidade de amostras presente no sinal.');
            elseif obj.endSample > length(audio)
                s = audio(obj.startSample:length(audio));
            else
                s = audio(obj.startSample:obj.endSample);
            end
        end
        
        % Função para determinar a quantidade necessária de iterações para
        % filtrar determinado sinal, dependendo do seu tamanho
        function iter = getIterSize(obj, audio)
            if rem(length(audio), obj.maxSampleQntd) == 0
                iter = length(audio)/obj.maxSampleQntd;
            else
                aux = rem(length(audio), obj.maxSampleQntd);
                iter = ((length(audio)-aux)/ obj.maxSampleQntd) + 1;
            end
        end
        
        % Função para calcular o SNR dos sinais recebidos por parâmetro
        function snr_db = mySNR(~, s, noise)
            R0 = mean(s.^2);
            vari = mean(noise.^2) - mean(noise)^2;
            snr_mag = R0/vari;
            snr_db = 10*log10(snr_mag);
        end
        
        % Função para plotar a FFT de um sinal recebido por parâmetro
        function plotFFT(~, signal, figNumber, titleTxt)
            figure(figNumber);
            normalizedSignal = signal/max(signal);
            fft_signal = fft(normalizedSignal)/length(signal);
            plot(abs(fft_signal));
            title(titleTxt);
        end
        
        function plotTime(obj, signal, figNumber, titleTxt)
            figure(figNumber);
            plot([1:length(signal)]/obj.fs,signal);
            xlabel('Tempo');
            title(titleTxt);
        end
        
        % Função para gravar um áudio de duração de 5 segundos com
        % frequência de amostragem fs
        function audio = recordAudio(obj)
            recObj = audiorecorder(obj.fs, 8, 1);
            disp('Início da gravação: Comece a falar.')
            recordblocking(recObj, 5);
            disp('Fim da gravação.');
            audio = getaudiodata(recObj);
        end
    end
end

