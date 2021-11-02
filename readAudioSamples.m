function [s,fs] = readAudioSamples(audioPath, startSample, endSample)
    info = audioinfo(audioPath);
    if startSample > info.TotalSamples
        error('Foi solicitada a leitura de um intervalo do sinal começando por uma amostra de número' ...
             +' maior do que a quantidade de amostras presente no sinal.');
    elseif endSample > info.TotalSamples
        [s,fs] = audioread(audioPath, [startSample, info.TotalSamples]);
    else
        [s,fs] = audioread(audioPath, [startSample, endSample]);
    end
end

