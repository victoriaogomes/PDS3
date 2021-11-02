function mu = getLMS_StepSize(un)
    acf = xcorr(un).';
    arrayMiddle = ((length(acf)-1)/2)+1;
    Rxx = acf(arrayMiddle:end);
    Rx = toeplitz(Rxx,[Rxx(1) conj(Rxx(2:end))]);
    autovalores = eig(Rx);
    maxVal = max(autovalores);
    minVal = min(autovalores);
    mu = 2/(maxVal+minVal);
end

