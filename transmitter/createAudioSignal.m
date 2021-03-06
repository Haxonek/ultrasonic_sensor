%% Sending data packet
% data frame information
bit_duration = 2*.001; % s

% high = 1 bit, low = 0 bit
hf = 17000;
lf = 15000;
% sampling rate * oversample
fs = 16*hf;

preamble = [1, 0, 1];
header = [0, 0, 1];
code = [1, 0, 1, 1, 1];
dist = [0, 1, 0, 0, 1, 0, 1, 0];

packet = [preamble, header, code, dist];

% convert into frequencies (Hz)
packet = ( abs(hf - lf) .* packet ) + lf;

ff = zeros(1, round(fs*bit_duration)*length(packet));

phase = 0;

for i = 1:length(packet)
    % for each data bit, transmit the corrisponding frequency for T seconds
    t = 0:1/fs:bit_duration;
    f = sin(2*pi*packet(i).*t + phase);
    
    % old phase is old phase plus new component (at end of sin wave)
    phase = phase + 2*pi*packet(i)*bit_duration;
    
    % combine into total length plot
    start_leg = length(t)*(i-1) + 1; % sub 1 to start i from 0, add 1 to start from 1 again
    end_leg = length(t)*(i);
    ff(start_leg:end_leg) = f;
        
end

% output audio
sound(ff, fs)

% audiowrite('syn-HF-17-LF-15-DUR-1ms.wav', ff, fs);

%% Plots of data

tt = (1:length(ff)).*(1/fs);

figure
plot(tt, ff)
title('output frequency')
xlabel('time (s)')
ylabel('frequency (Hz)')

FF = fftshift(fft(ff));
nn = (-length(FF)/2:length(FF)/2-1)/length(FF);

figure
subplot(2,1,1)
plot(nn, abs(FF))
title('FFT plot, with shift')
xlabel('Normalized frequency')
ylabel('|DFT values|')

power = FF.*conj(FF)/(length(FF)*length(ff));

subplot(2,1,2)
plot((nn.*fs), 10*log10(power))
title('FFT plot, with shift')
xlabel('Frequency (Hz)')
ylabel('Power (dB)')



%% Sending data packet WITH NOISE
% data frame information
bit_duration = 2*.001; % s

% high = 1 bit, low = 0 bit
hf = 17000;
lf = 15000;
% sampling rate * oversample
fs = 16*hf;

preamble = [1, 0, 1];
% header = [0, 0, 1];
% code = [1, 0, 1, 1, 1];
% dist = [0, 1, 0, 0, 1, 0, 1, 0];

% packet = [preamble, header, code, dist];
packet = preamble;

% convert into frequencies (Hz)
packet = ( abs(hf - lf) .* packet ) + lf;

ff = zeros(1, round(fs*bit_duration)*length(packet));

phase = 0;

for i = 1:length(packet)
    % for each data bit, transmit the corrisponding frequency for T seconds
    t = 0:1/fs:bit_duration;
    f = sin(2*pi*packet(i).*t + phase) + rand()/10;
    
    if (i == 2)
        disp(i)
        bd = bit_duration;
        f(15:30) = f(15:30) + sin(2*pi*18000.*(15/fs:1/fs:30/fs) + phase);
    end
    
    if (i == 2)
        disp(i)
        bd = bit_duration;
        f(150:165) = f(150:165) + sin(2*pi*18000.*(150/fs:1/fs:165/fs) + phase);
    end
    
    if (i == 3)
        disp(i)
        bd = bit_duration;
        f(15:30) = f(15:30) + sin(2*pi*21000.*(15/fs:1/fs:30/fs) + phase);
    end
    
    if (i == 1)
        disp(i)
        bd = bit_duration;
        f(45:65) = f(45:65) + sin(2*pi*14000.*(45/fs:1/fs:65/fs) + phase);
    end
    
    % old phase is old phase plus new component (at end of sin wave)
    phase = phase + 2*pi*packet(i)*bit_duration;
    
    % combine into total length plot
    start_leg = length(t)*(i-1) + 1; % sub 1 to start i from 0, add 1 to start from 1 again
    end_leg = length(t)*(i);
    ff(start_leg:end_leg) = f;
    
end

figure
plot(1:length(ff), ff)

sound(ff,fs)

% output audio
audiowrite('syn-pulse-18-HF-17-LF-16-DUR-1ms.wav', ff, fs);



