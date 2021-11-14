% clear all;
close all;
load handel;
%% Parâmetros fixos
M = 2;

%% Inicializando parâmetros do LMS
w1 = zeros(M,1); 

%% Aplicação do LMS
% audio + white noise
start = 1;
maxSampleQntd = 2000;
%% Gravação do áudio
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
% noise = randn(maxSampleQntd+1,1)*nvar;% White noise
% noise = delayseq(audio, 250);
n0 = 25;
len = length(audio) - n0;
noise = zeros(length(audio), 1);
for i = 1:len
    noise(i) = audio(i+n0);
end
%% Cálculo do p
I = eye(M);
a = 0.01;
p = a * I;

%% Valor de lambda
lambda = 0.99;

%% Execução do LMS
max_i = iter;
u = zeros(M, 1); 
for i = 1 : max_i
    disp(i);
    %% Carrega a parte do sinal que será processada agora
    if startSample > length(audio)
        error('Foi solicitada a leitura de um intervalo do sinal começando por uma amostra de número' ...
             +' maior do que a quantidade de amostras presente no sinal.');
    elseif i*maxSampleQntd > length(audio)
        dn = audio(startSample: length(audio));
        noise_part = noise(startSample: length(audio));
    else
        dn = audio(startSample: i*maxSampleQntd);
        noise_part = noise(startSample: i*maxSampleQntd);
    end
    
    %% Cálculo do valor de mu
    if i == 1
%         hada = noise.*noise;
%         denom = mean(hada)*M;
%         mumax = 2/denom;
%         mu = mumax/10;
%         acf = xcorr(noise_part).';
%         arrayMiddle = ((length(acf)-1)/2)+1;
%         Rxx = acf(arrayMiddle:end);
%         Rx = toeplitz(Rxx,[Rxx(1) conj(Rxx(2:end))]);
%         autovalores = eig(Rx);
%         maxVal = max(autovalores);
%         minVal = min(autovalores);
%         mu = 2/(maxVal+minVal);
    end
    if exist('snr_entrada', 'var')
        snr_entrada = [snr_entrada mySNR(dn, noise_part)];
    else
        snr_entrada = mySNR(dn, noise_part);
    end
    mu = 0.001;
    tic
%     [e1, y1, w1, xx] = myLMS(s, noise_part, mu, M, w1);
    %[y1, e1, w1, u] = lms_da_vic(dn, noise_part, w1, mu, u);
    [e1, y1, w1, u, p] = myRLS(dn, noise_part, lambda, M, w1, p, u);
    toc
    if exist('output_e1','var')
        output_e1 = [output_e1 e1.'];
    else
        output_e1 = e1.';
    end
    if exist('snr_saida', 'var')
        snr_saida = [snr_saida mySNR(e1, y1)];
    else
        snr_saida = mySNR(e1, y1);
    end
    %% Atualiza amostra de onde começaremos a carregar o próximo pedaço do
    % sinal
    startSample = i*maxSampleQntd + 1;

%     plot
%     figure;
%     H  = abs(freqz(w1,1,M*2));
%     H1 = abs(freqz(lp.Numerator,1,M*2));
%     wf = linspace(0,1,M*2);
%     plot(wf,H,wf,H1);
%     xlabel('Normalized Frequency  (\times\pi rad/sample)');
%     ylabel('Magnitude');
%     legend('Adaptive Filter Response','Required Filter Response');
%     grid;
%     axis([0 1 0 2]);
%     disp('SNR NOSSO ANTES');
%     disp(mySNR(d, n));
%     disp('SNR NOSSO DPS');
%     disp(mySNR(e1, n));
%     disp('SNR MATLAB ANTES');
%     disp(snr(d,n));
%     disp('SNR MATLAB DPS');
%     disp(snr(e1,n));
end 
% mu2max = 2/((M+1)*Rx(1)); % 0.00001575342821396935

%Filtro


plot(output_e1);

figure()
subplot(2,2,1)
plot([1:length(audio)]/fs,audio);
xlabel('time');
title('sinal limpo');
% subplot(2,2,2)
% plot([1:length(d_total)]/fs,d_total);
% xlabel('time');
% title('d(n)');
subplot(2,2,3)
plot([1:length(output_e1)]/fs,output_e1);
xlabel('time');
title('LMS e(n)');
