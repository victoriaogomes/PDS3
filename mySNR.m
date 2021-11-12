function snr_db = mySNR(s, noise)
    R0 = mean(s.^2);
    vari = mean(noise.^2) - mean(noise)^2;
    snr_mag = R0/vari;
    snr_db = 10*log10(snr_mag);
end