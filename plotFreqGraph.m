function plotFreqGraph(signal, fs, numFig, graphLegend)
    fftSignal = fft(signal)/length(signal);
    mag = abs(fftshift(fftSignal));
    freq = -fs/2 : fs/(length(signal)-1) : fs/2;
    figure(numFig);
    stem(freq, mag); 
    legend(graphLegend);
end

