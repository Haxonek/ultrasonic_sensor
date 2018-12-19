
[x, fs] = audioread('sound_samples/HF17-LF15-DUR-2ms.wav');
% [x, fs] = audioread('sound_samples/HF17-LF15-DUR-2ms.wav');

% x = x((4*fs):length(x)-(2*fs), 1); % 1 s plot
% x = x((5.24*fs):(5.28*fs), 1); % .2ms plot
x = x(fs*2.17:2.26*fs, 1); % 2ms plot
% x = x(fs*2:2.2*fs, 1);

L = length(x);

% Y = fft(x);
% P2 = abs(Y/L);
% P1 = P2(1:L/2+1);
% P1(2:end-1) = 2*P1(2:end-1);

% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of S(t)')
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

% [val, ind] = max(P1);
% display(f(ind))

r = 2; % resolution, larger is worse

frequencies = zeros(ceil(length(x)/(2*r*fs/1000)), 1);
epsilon = 10; % Hz
hf = 180;
lf = 160;

index = 0;
figure
for xx = 1:2*r*fs/1000:length(x)
        
    index = index + 1;
    
    xx = round(xx);
    
    X = x( xx:min(xx+round(fs/1000 - 1), length(x)) );
    
    Y = fft(X);
    P2 = abs(Y/length(X));
    P1 = P2(1:length(X)/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    
    [val, ind] = max(P1);
    frequencies(index) = f(ind);
    
    scatter(index, f(ind)); hold on;

end
title('FFT individual data points, bit duration of 2ms')
xlabel('Increments of 2ms')

display(index)

bits = zeros(length(frequencies), 1);
% read message
for i = 1:length(frequencies)
    freq = frequencies(i);
    
    if ((freq > (lf - epsilon)) && (freq < (lf + epsilon)))
%         fprintf('bit: 0\n');
    elseif (freq > (hf - epsilon) && freq < (hf + epsilon))
%         fprintf('bit: 1\n');
        bits(i) = 1;
    else
%         fprintf('bit: none \n');
        bits(i) = -1;
    end

end

for i = 1:length(bits)
    
    if i + 6 > length(bits)
        break;
    end
    
    isPreamble = findMessageV1(bits(i:i+6));
    if (isPreamble)
        disp('Found Preable')
    
        code = getCode(bits(i+6:i+11));
        disp(code);

        distance = getDistance(i+11:i+19);
        disp(distance);
    end
    
%      1  0  1
%      0  0  1
%      1  0  1  1  1 code
%      0  1  0  0    distance
    
end
