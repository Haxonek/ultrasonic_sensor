%% Matlab attempt to receive audio
% best attempt is the very bottom one, running with 1s it seems to work
% well, but has issues with the 2ms data

format long

[y, fs] = audioread('sound_samples/HF17-LF15-DUR-1s.wav');

figure
plot(1:length(y), y)
title('Audio plot')

% soundsc(y,fs)

Nfft = 1024;
[Pxx,f] = pwelch(y,gausswin(Nfft),Nfft/2,Nfft,fs);

figure
plot(f,Pxx);
ylabel('PSD');
xlabel('Frequency (Hz)');
grid on;
% Get frequency estimate (spectral peak)
[~,loc] = max(Pxx);
FREQ_ESTIMATE = f(loc)
title(['Frequency estimate = ',num2str(FREQ_ESTIMATE),' Hz']);

%% re calculate but iterativly, T = .1ms

i = 1;
frequencies = zeros(ceil(length(Pxx)/5));
while i <= length(Pxx)
    sum = 0;
    for j = 0:4
        if i+j <= length(Pxx)
            sum = sum + Pxx(i + j);
            display(sum)
        end
    end
    frequencies(ceil(i/5)) = sum / 5;
    i = i + 5;
end

figure
plot(1:length(frequencies), frequencies)


%% 

NFFT = 128;
freqsTmp = zeros(1, ceil(length(y)/NFFT));


for i = 1:length(y)
    
    % break y into segments of 5 values
    tmp = y(i:i+NFFT - 1);
    
    % calculate Pxx
    [PxxTmp,fTmp] = pwelch(tmp,gausswin(NFFT),NFFT/2,NFFT,fs);
    
    % get frequency
%     plot(fTmp, PxxTmp); hold on;
    
    % plot out average frequency
%     index = find(PxxTmp == max(PxxTmp));
    % maybe calculate sum at this point
    
    freqsTmp(ceil(i/NFFT)) = sumArray(PxxTmp .* fTmp);
    
    % increment i
    i = i + NFFT;
%     display(i)
    
end

figure()
plot(1:length(freqsTmp), freqsTmp)

%% ONLINE GUIDE https://www.mathworks.com/help/signal/examples/practical-introduction-to-time-frequency-analysis.html


[tones, Fs] = helperDTMFToneGenerator();
p = audioplayer(tones,Fs,16);
% play(p)


N = numel(tones);
t = (0:N-1)/Fs; 
subplot(2,1,1)
plot(1e3*t,tones)
xlabel('Time (ms)')
ylabel('Amplitude')
title('DTMF Signal')
subplot(2,1,2)
spectrum(tones,Fs,'Leakage',1,'FrequencyLimits',[650, 1500])

env = envelope(tones,80,'rms');
pulsewidth(env,Fs)

title('Pulse Width of RMS Envelope')

f = [meanfreq(tones,Fs,[700 800]), ...
     meanfreq(tones,Fs,[800 900]), ...
     meanfreq(tones,Fs,[900 1000]), ...
     meanfreq(tones,Fs,[1300 1400])];
round(f)

spectrum(tones,Fs,'spectrogram','Leakage',1,'OverlapPercent',0, ...
    'MinThreshold',-10,'FrequencyLimits',[650, 1500]);





%% BEST WORKING METHOD SO FAR

format long

% [x, fs] = audioread('sound_samples/HF17-LF15-DUR-2ms.wav');
[x, fs] = audioread('sound_samples/HF17-LF15-DUR-2ms.wav');
% [x, fs] = audioread('syn-plse-18-HF-17-LF-16-DUR-1ms.wav');

% x = x((4*fs):length(x)-(2*fs), 1); % 1 s plot
% x = x((5.24*fs):(5.28*fs), 1); % .2ms plot
x = x(fs*2.17:2.26*fs, 1); % 2ms plot
% x = x(fs*2:2.2*fs, 1);
% x = x(:, 1);

wlen = 2^6;                        % window length (recomended to be power of 2) 2^10
hop = wlen/2^2;                       % hop size (recomended to be power of 2) 2^2
nfft = 2^17; % 14                        % number of fft points (recomended to be power of 2) 2^12

% perform STFT
win = blackman(wlen, 'periodic');
[S, f, t] = stft(x, win, hop, nfft, fs);

% calculate the coherent amplification of the window
C = sum(win)/wlen;

% take the amplitude of fft(x) and scale it, so not to be a
% function of the length of the window and its coherent amplification
S = abs(S)/wlen/C;


% correction of the DC & Nyquist component
if rem(nfft, 2)                     % odd nfft excludes Nyquist point
    S(2:end, :) = S(2:end, :).*2;
else                                % even nfft includes Nyquist point
    S(2:end-1, :) = S(2:end-1, :).*2;
end


% convert amplitude spectrum to dB (min = -120 dB)
S = 20*log10(S + 1e-6);
% plot the spectrogram
figure(1)
surf(t, f, S); hold on;
shading interp
axis tight
view(0, 90)
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Frequency, Hz')
title('Amplitude spectrogram of the signal at 2ms')
hcol = colorbar;
set(hcol, 'FontName', 'Times New Roman', 'FontSize', 14)
ylabel(hcol, 'Magnitude, dB')
ylim([12000,22000])

% plot line on power spectrum plot
center_frequenies = ones(length(t)) .* 16000;

plot(t, center_frequenies)


%% plot errors per delta f

delta_f = [2000, 1000, 500, 250, 125, 62.5];
errors = [0, 0, 0, 0, 0, 2];

figure
plot(delta_f, errors); axis on;
title('Single bit errors at frequencies of \Delta f')
xlabel('\Delta f from f_{c}')
ylabel('Errors for each axis')
ylim([-1,5])

% axis([pl1],[2000 62.5 -1 9])

%% Probability

format long

n = 1:12;

figure
for total = 160

    prob = 1 - (factorial(total) ./ (total.^n .* factorial(total - n)));
    
    plot(n, prob); hold on;

    
end

prob2 = [0, .003125, .0093554, .018624, .030909, .046051, .063938, .08441, .107304, .13241, .1595, .18841];
prob9 = zeros(length(n));
for i = length(n)
    prob9(i) = prob2(i) * (1-prob2(i))^9;
end
    
plot(n, prob2)

title('Probability of interference in one')
xlabel('Cars on road within ultrasonic range')
ylabel('Probability of collision among n car(s)')
legend('160', '320')