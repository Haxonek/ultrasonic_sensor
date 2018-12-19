recObj = audiorecorder;

recordblocking(recObj, 2);

% play(recObj);

y = getaudiodata(recObj);

fs = 8000;

audiowrite('pulse-18-HF-17-LF-16-DUR-2ms.wav', y, fs)

figure
plot(1:length(y), y)
title('signal plot of listen audio')