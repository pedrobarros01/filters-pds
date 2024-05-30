clear
close all


fs = 44100; %  44,1 kHz
fc_passa_baixa = 0;
fc_pass_faixa = 250; 
fc_passa_alta = 2000; 



arquivo1 = "AUDIO_HENRIQUE";
arquivo2 = "OST_OUTER_WILDS_TRAVELERS";
filename = arquivo2;
info = audioinfo( strcat(filename, '.mp3') )
[x, ] = getRec(strcat(filename, '.mp3'));

%especificações
%ripple = 1; % Ripple máximo na banda de passagem (em dB)
%attenuacao = 60; % Atenuação na banda de rejeição (em dB)
%banda_transicao = 1; %banda de transição (em oitavas)(dobro ou metade da
%freq de corte)

% Filtro passa-baixa - 0 a 250 Hz (faixa de graves) 
% Filtro passa-faixa -  250 a 2 kHz (faixa de médios)
% Filtro passa-alta -  2 kHz (faixa de agudos) 




dlowfir = designfilt('lowpassfir','PassbandFrequency', 2, 'StopbandFrequency', 500,  'StopbandAttenuation', 60, 'PassbandRipple', 1,'SampleRate', 44100, 'DesignMethod', 'kaiserwin');
dmidfir  = designfilt('bandpassfir', 'StopbandFrequency1', 125, 'PassbandFrequency1', 375, 'PassbandFrequency2', 1875, 'StopbandFrequency2', 4000, 'StopbandAttenuation1', 60, 'PassbandRipple', 1, 'StopbandAttenuation2', 60, 'SampleRate', 44100, 'DesignMethod', 'kaiserwin');
dhighfir = designfilt('highpassfir', 'StopbandFrequency', 1000,'PassbandFrequency', 3000,  'StopbandAttenuation', 60, 'PassbandRipple', 1,'SampleRate', 44100, 'DesignMethod', 'kaiserwin');
dlowiir = designfilt('lowpassiir', ...        
       'PassbandFrequency',200, ...     
       'StopbandFrequency',500, ...
       'PassbandRipple',1, ...         
       'StopbandAttenuation',60, ...
       'DesignMethod','butter', ...     
       'MatchExactly','stopband', ...   
       'SampleRate',44100);


dmidiir = designfilt('bandpassiir', ...      
       'StopbandFrequency1',125, ...  
       'PassbandFrequency1',250, ...
       'PassbandFrequency2',2000, ...
       'StopbandFrequency2',4000, ...
       'StopbandAttenuation1',60, ...   
       'PassbandRipple',1, ...
       'StopbandAttenuation2',60, ...
       'DesignMethod','butter', ...      
       'MatchExactly','stopband', ...  
       'SampleRate',44100) 


dhighiir = designfilt('highpassiir', ...      
       'StopbandFrequency',1000, ...     
       'PassbandFrequency',2500, ...
       'StopbandAttenuation',60, ...    
       'PassbandRipple',1, ...
       'DesignMethod','butter', ...    
       'MatchExactly','stopband', ...   
       'SampleRate',44100)


filtered_low_fir = filter(dlowfir, x);
filtered_medium_fir = filter(dmidfir, x);
filtered_high_fir = filter(dhighfir, x);

voiceFilteredLowIIR = filter(dlowiir, x);
voiceFilteredMidIIR = filter(dmidiir, x);
voiceFilteredHighIIR = filter(dhighiir, x);

%Resposta ao Impulso para FIR
impulse_response_low_fir = impz(dlowfir);
impulse_response_medium_fir = impz(dmidfir);
impulse_response_high_fir = impz(dhighfir);

%Resposta ao Impulso para IIR
impulse_response_low_iir = impz(dlowiir);
impulse_response_medium_iir = impz(dmidiir);
impulse_response_high_iir = impz(dhighiir);

%Plotagem resposta ao impulso para FIR
figure;
subplot(3,1,1);
stem(impulse_response_low_fir);
title('Resposta ao Impulso - FIR|PASSA BAIXA');

subplot(3,1,2);
stem(impulse_response_medium_fir);
title('Resposta ao Impulso - FIR|PASSA FAIXA');

subplot(3,1,3);
stem(impulse_response_high_fir);
title('Resposta ao Impulso - FIR|PASSA ALTA');

% Plotagem resposta ao impulso para IIR
figure;
subplot(3,1,1);
stem(impulse_response_low_iir);
title('Resposta ao Impulso - IIR|PASSA BAIXA');

subplot(3,1,2);
stem(impulse_response_medium_iir);
title('Resposta ao Impulso - IIR|PASSA FAIXA');

subplot(3,1,3);
stem(impulse_response_high_iir);
title('Resposta ao Impulso - IIR|PASSA ALTA');

% plotagem sinal de entrad
figure;
plot(x, 'r');
xlabel('Time')
ylabel('Audio Signal')
title('Original');


% Plotagem dos sinais filtrados em FIR 
figure;
hold on
plot(x, 'r');
plot(filtered_low_fir, 'b');
title('Sinal Filtrado com FIR/Passa baixa');
xlabel('Time')
ylabel('Audio Signal')

hold off

figure;
hold on
plot(x, 'r');
plot(filtered_medium_fir, 'b');

title('Sinal Filtrado com FIR/Passa faixa');
xlabel('Time')
ylabel('Audio Signal')

hold off

figure;
hold on
plot(x, 'r');
plot(filtered_high_fir, 'b');
title('Sinal Filtrado com FIR/Passa alta');
xlabel('Time')
ylabel('Audio Signal')

hold off


% Plotagem dos sinais filtrados em IIR
figure;
hold on
plot(x, 'r');
plot(voiceFilteredLowIIR, 'b');
title('Sinal Filtrado com IIR/Passa baixa');
xlabel('Time')
ylabel('Audio Signal')

hold off

figure;
hold on
plot(x, 'r');
plot(voiceFilteredMidIIR, 'b');
title('Sinal Filtrado com IIR/Passa faixa');
xlabel('Time')
ylabel('Audio Signal')

hold off

figure;
hold on
plot(x, 'r');
plot(voiceFilteredHighIIR, 'b');
title('Sinal Filtrado com IIR/Passa alta');
xlabel('Time')
ylabel('Audio Signal')
hold off

audiowrite(strcat(filename,"_fir_low.wav"), filtered_low_fir, fs);
audiowrite(strcat(filename,"_fir_medium.wav"), filtered_medium_fir, fs);
audiowrite(strcat(filename,"_fir_high.wav"), filtered_high_fir, fs);

audiowrite(strcat(filename,"_iir_low.wav"), voiceFilteredLowIIR, fs);
audiowrite(strcat(filename,"_iir_medium.wav"), voiceFilteredMidIIR, fs);
audiowrite(strcat(filename,"_iir_high.wav"), voiceFilteredHighIIR, fs);