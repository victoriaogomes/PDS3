function iter = getIterQntd(audioPath, maxSampleQntd)
    info = audioinfo(audioPath);
    if rem(info.TotalSamples, maxSampleQntd) == 0
        iter = info.TotalSamples/maxSampleQntd;
    else
        aux = rem(info.TotalSamples, maxSampleQntd);
        iter = ((info.TotalSamples-aux)/maxSampleQntd) + 1;
    end
end