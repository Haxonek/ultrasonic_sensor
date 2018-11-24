%% Sending data packet
% data frame information
bit_duration = 1; % s

% high = 1 bit, low = 0 bit
hf = 17000;
lf = 15000;
% sampling rate * oversample
fs = 16*hf;

preamble = [1, 0, 1];
header = [0, 0, 1];
data = [1, 0, 1, 1, 1, 0, 1, 0];

packet = [preamble, header, data];

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



%%




