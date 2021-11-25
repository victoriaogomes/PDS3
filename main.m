close all;
clear all;

%% Carregamento do áudio que será filtrado
disp('--> Olá!')
disp("Informe o nome do arquivo que gostaria de filtrar usando como base " ...
    + newline + "o RLS e LMS, ou digite -1 para usar o áudio default da aplicação");
audioToLoad = input('Nome do arquivo: ');

if audioToLoad == -1
    aux = load('audio_app_frequency.mat');
    fns = fieldnames(aux);
    audio = aux.(fns{1});
else
    audio = audioread(audioToLoad);
end

%% Definição do sinal de referência
n0 = 25;
len = length(audio) - n0;
noise = zeros(length(audio), 1);
for i = 1:len
    noise(i) = audio(i+n0);
end

%% Declaração de objeto com funções auxiliares para o funcionamento do programa
auxiliarFunc = AuxiliarFunctions();

%% Aplicação da filtragem com o LMS
lmsModel = LMSModel();
lmsModel.filterSignal(audio, noise, auxiliarFunc);

%% Aplicação da filtragem com o RLS
rlsModel = RLSModel();
rlsModel.filterSignal(audio, noise, auxiliarFunc);

%% Feedback para o usuário
disp(newline + "-- > Resultados");
disp("-- LMS: ");
disp("- Tempo necessário para execução " + ...
    lmsModel.elapsedTime + " segundos");
disp("- SNR do sinal de entrada: " + ...
    auxiliarFunc.mySNR(audio, noise));
disp("- SNR do sinal de saída: " + ...
    auxiliarFunc.mySNR(lmsModel.filteredSignal, lmsModel.estimatedNoise));

disp("-- RLS: ");
disp("- Tempo necessário para execução " + ...
    rlsModel.elapsedTime + " segundos");
disp("- SNR do sinal de entrada: " + ...
    auxiliarFunc.mySNR(audio, noise));
disp("- SNR do sinal de saída: " + ...
    auxiliarFunc.mySNR(rlsModel.filteredSignal, rlsModel.estimatedNoise));

%% Opção para visualização de gráficos

option = 0;
figNumber = 1;

while option ~= -1
    disp(newline + "--> Qual dado gostaria de visualizar?");
    disp("1 - Gráfico do sinal de entrada");
    disp("2 - Gráfico do sinal filtrado pelo LMS");
    disp("3 - Gráfico do ruído estimado pelo LMS");
    disp("4 - Gráfico do sinal filtrado pelo RLS");
    disp("5 - Gráfico do ruído estimado pelo RLS");
    disp("Para sair, digite -1");
    option = input('Opção selecionada: ');
    if option ~= -1
        disp("--> Em que domínio gostaria de visualizar essas informações?");
        disp("1 - Domínio do tempo");
        disp("2 - Domínio da frequência");
        graphType = input('Opção selecionada: ');
        switch option
            case 1
                signalToPlot = audio;
                title = "Sinal de entrada";
            case 2
                signalToPlot = lmsModel.filteredSignal;
                title = "Sinal filtrado pelo LMS";
            case 3
                signalToPlot = lmsModel.estimatedNoise;
                title = "Ruído estimado pelo LMS";
            case 4
                signalToPlot = rlsModel.filteredSignal;
                title = "Sinal filtrado pelo RLS";
            case 5
                signalToPlot = rlsModel.estimatedNoise;  
                title = "Ruído estimado pelo RLS"; 
        end

        switch graphType
            case 1
                title = title + " no domínio do tempo";
                auxiliarFunc.plotTime(signalToPlot, figNumber, title);
            case 2
                title = title + " no domínio da frequência";
                auxiliarFunc.plotFFT(signalToPlot, figNumber, title);
        end
        figNumber = figNumber + 1;
    end
end

return;
