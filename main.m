clear all;
close all;
load handel;
%% Parâmetros fixos
M = 10;

%% Inicializando parâmetros do LMS
w1 = zeros(M,1); 

%% Aplicação do LMS
% audio + white noise
start = 1;
maxSampleQntd = 2000;
%% sla
fs = 8000;
recObj = audiorecorder(fs, 8, 1);
disp('Start speaking.')
recordblocking(recObj, 5);
disp('End of Recording.');
audio = getaudiodata(recObj);
startSample = 1;

%% Cálculo de quantas iterações são necessárias para filtrar todo o sinal
if rem(length(audio), maxSampleQntd) == 0
    iter = length(audio)/maxSampleQntd;
else
    aux = rem(length(audio), maxSampleQntd);
    iter = ((length(audio)-aux)/maxSampleQntd) + 1;
end
%% Definição do sinal de referência
nvar  = 1.0;                          % Noise variance
noise = randn(maxSampleQntd+1,1)*nvar;% White noise
% mu = 0.001;
%% Execução do LMS
max_i = iter;
for i = 1 : max_i
    %% Carrega a parte do sinal que será processada agora
    if startSample > length(audio)
        error('Foi solicitada a leitura de um intervalo do sinal começando por uma amostra de número' ...
             +' maior do que a quantidade de amostras presente no sinal.');
    elseif i*maxSampleQntd > length(audio)
        s = audio(startSample: length(audio));
    else
        s = audio(startSample: i*maxSampleQntd);
    end
    if exist('s_total','var')
        s_total = [s_total s.'];
    else
        s_total = s.';
    end
    %% Definição do sinal de entrada: sinal de informação (s) + ruído relacionado a referência
    lp = dsp.FIRFilter('Numerator', fir1(M-1,0.5));% Low pass FIR filter
    n = lp(noise(1:length(s)));
    d = n + s;
    if exist('d_total','var')
        d_total = [d_total d.'];
    else
        d_total = d.';
    end
    %% Cálculo do valor de mu
    if i == 1
        hada = noise.*noise;
        denom = mean(hada)*M;
        mumax = 2/denom;
        
        mu = mumax/10;
    end 
    tic
    [e1, y1, w1, xx] = myLMS(d, noise(1:length(s)), mu, M, w1);
    toc
    if exist('output_e1','var')
        output_e1 = [output_e1 e1.'];
    else
        output_e1 = e1.';
    end
    %% Atualiza amostra de onde começaremos a carregar o próximo pedaço do
    % sinal
    startSample = i*maxSampleQntd + 1;
    %plot
    figure;
    H  = abs(freqz(w1,1,M*2));
    H1 = abs(freqz(lp.Numerator,1,M*2));

    wf = linspace(0,1,M*2);
    plot(wf,H,wf,H1);
    xlabel('Normalized Frequency  (\times\pi rad/sample)');
    ylabel('Magnitude');
    legend('Adaptive Filter Response','Required Filter Response');
    grid;
    axis([0 1 0 2]);
    disp('Nosso SNR');
    disp(ro(d, n));
    disp('SNR do MATLAB');
    disp(snr(d, n));
end 
% mu2max = 2/((M+1)*Rx(1)); % 0.00001575342821396935

%Filtro


plot(output_e1);

figure()
subplot(2,2,1)
plot([1:length(s_total)]/fs,s_total);
xlabel('time');
title('sinal limpo');
subplot(2,2,2)
plot([1:length(d_total)]/fs,d_total);
xlabel('time');
title('d(n)');
subplot(2,2,3)
plot([1:length(output_e1)]/fs,output_e1);
xlabel('time');
title('LMS e(n)');
