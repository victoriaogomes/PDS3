clear all;
load handel;
%% Parâmetros fixos
M = 10;

%% Inicializando parâmetros do LMS
w1 = zeros(M,1); 

%% Aplicação do LMS
% audio + white noise
start = 1;
maxSampleQntd = 3000;

%% Cálculo de quantas iterações são necessárias para filtrar todo o sinal
info = audioinfo('handel.wav');
if rem(audioinfo('handel.wav').TotalSamples, maxSampleQntd) == 0
    max_i = audioinfo('handel.wav').TotalSamples/maxSampleQntd;
else
    aux = rem(audioinfo('handel.wav').TotalSamples, maxSampleQntd);
    max_i = ((audioinfo('handel.wav').TotalSamples-aux)/maxSampleQntd) + 1;
end
%% Definição do sinal de referência
nvar  = 1.0;                          % Noise variance
noise = randn(maxSampleQntd+1,1)*nvar;% White noise
% mu = 0.001;
%% Execução do LMS
for i = 1 : max_i
    %% Carrega a parte do sinal que será processada agora
    if i == max_i
        [s,fs] = audioread('handel.wav', [start, audioinfo('handel.wav').TotalSamples]);
    else
        [s,fs] = audioread('handel.wav', [start, i*maxSampleQntd]);
    end
    if exist('s_total','var')
        s_total = [s_total s.'];
    else
        s_total = s.';
    end
    %% Definição do sinal de entrada: sinal de informação (s) + ruído relacionado a referência
    lp = dsp.FIRFilter('Numerator', fir1(M-1,0.5));% Low pass FIR filter
    d = lp(noise(1:length(s))) + s;
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
%         
%         acf = xcorr(d).';
%         arrayMiddle = ((length(acf)-1)/2)+1;
%         Rxx = acf(arrayMiddle:end); % R_xx(0) is the center element
%         Rx = toeplitz(Rxx,[Rxx(1) conj(Rxx(2:end))]);
%         autovalores = eig(Rx);
%         maxVal = max(autovalores);
%         minVal = min(autovalores);
%         mu = 2/(maxVal+1);
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
    start = i*maxSampleQntd + 1;
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
