clear all;
%% Parâmetros relativos ao filtro FIR
M = 30;               % Ordem do filtro
w = zeros(M,1);      % Vetor que armazena os coeficientes do filtro

%% Definição de variáveis auxiliares para o processamento do sinal
start = 1;            % Amostra inicial a ser pega (atualizado a cada iteração)
maxSampleQntd = 3000; % Quantidade máxima de amostras do sinal processada a cada iteração

%% Definição do sinal de referência - u(n)
nvar  = 1.0;                          % Variância do ruído
un = randn(maxSampleQntd+1,1)*nvar;   % Geração de um ruído branco

%% Definição do filtro que será utilizado para gerar o sinal de ruído adicionado a s(n)
lp = dsp.FIRFilter('Numerator', fir1(M-1,0.5)); 

%% Definição do passo utilizado no algoritmo LMS
% mu = 0.001;
mu = getLMS_StepSize(un);

%% Execução do LMS
for i = 1 : getIterQntd('handel.wav', maxSampleQntd)
    %% Carregamento da parte do sinal que será processada nessa iteração
    [sn, fs] = readAudioSamples('handel.wav', start, i*maxSampleQntd);

    %% Definição do sinal de entrada primário: sinal de informação s(n) + ruído relacionado a referência v(n)
    vn = lp(un(1:length(sn))) ;
    dn = sn + vn;
    
    %% Chamada ao método LMS para atualização dos coeficientes do filtro
    tic
    [e1, y1, w, ~] = myLMS(dn, un(1:length(sn)), mu, M, w);
    toc
    
    %% Atualização da amostra de onde começaremos a carregar o próximo pedaço do sinal
    start = i*maxSampleQntd + 1;
    
    %% Atualização dos vetores que contém os sinais manipulados 
    if i == 1
        s_total   = sn.';
        d_total   = dn.';
        output_e1 = e1.';
    else
        s_total =   [s_total sn.'];
        d_total =   [d_total dn.'];
        output_e1 = [output_e1 e1.'];
    end
end 
% mu2max = 2/((M+1)*Rx(1)); % 0.00001575342821396935

%Filtro

hold on;
plotFreqGraph(dn, fs, 1, 'Sinal + ruído');
plotFreqGraph(sn, fs, 1, 'Sinal de informação');
plotFreqGraph(vn, fs, 1, 'Sinal de informação');
hold off;


% plot(output_e1);
% 
% figure()
% subplot(2,2,1)
% plot([1:length(s_total)]/fs,s_total);
% xlabel('time');
% title('sinal limpo');
% subplot(2,2,2)
% plot([1:length(d_total)]/fs,d_total);
% xlabel('time');
% title('d(n)');
% subplot(2,2,3)
% plot([1:length(output_e1)]/fs,output_e1);
% xlabel('time');
% title('LMS e(n)');
% 
% figure;
% H  = abs(freqz(w,1,M*2));
% H1 = abs(freqz(lp.Numerator,1,M*2));
% 
% wf = linspace(0,1,M*2);
% 
% plot(wf,H,wf,H1);
% xlabel('Normalized Frequency  (\times\pi rad/sample)');
% ylabel('Magnitude');
% legend('Adaptive Filter Response','Required Filter Response');
% grid;
% axis([0 1 0 2]);
