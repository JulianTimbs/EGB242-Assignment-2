%% EGB242 Assignment 2, Section 1 %%
% This file is a template for your MATLAB solution to Section 1.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;
load DataA2 audioMultiplexNoisy fs sid;

% Begin writing your MATLAB solution below this line.

%% 1.1

audio = audioMultiplexNoisy;
samples = length(audio);
ts = 1/fs;
T = samples/fs;

t = (0:samples-1)/fs;

f = linspace(-fs/2, fs/2, samples +1);
f(end) = [];


% frequency domain representation
audiof = fftshift(fft(audio))/samples;

% time domain plot
figure
plot(t, audio)
xlabel('Time (s)')
ylabel('Amplitude')
title('Noisy Multiplexed Audio Signal in the Time Domain')
grid on

% frequency domain plot
figure;
plot(f, abs(audiof))
xlabel('Frequency [Hz]')
ylabel('Magnitude')
title('Noisy Multiplexed Audio Signal in the Frequency Domain')
grid on

%% 1.2

carrierF = [72080 56030 40150 24290 8320];
cutoffF = 2000;

demodAudio = demodStreams(audio, carrierF, cutoffF, fs, 'Noisy');



%% 1.3

inputImpulse = [1/ts, zeros(1, samples-1)];

h = channel(sid, inputImpulse, fs);

H = fftshift(fft(h)) * ts;

noisyAudio = fftshift(fft(audio)) / samples;


figure;
plot(t, h);
xlabel('Time (s)');
ylabel('Amplitude');
title('Impulse Response of the Channel');
grid on;

% Plot H(f) and audioMultiplexNoisy spectrum on same axes

figure;
plot(f, abs(H)/max(abs(H)), 'LineWidth', 1.2);
hold on;
plot(f, abs(noisyAudio)/max(abs(noisyAudio)));
xlabel('Frequency [Hz]');
ylabel('Normalised Magnitude');
title('Channel Frequency Response and Noisy Multiplexed Audio Spectrum');
legend('|H(f)|', '|AudioMultiplexNoisy(f)|');
grid on;


%% 1.4

H = fft(h) * ts;
Y = fft(audio);

X = Y ./ H;

cleanAudio = real(ifft(X));
cleanAudio = cleanAudio - mean(cleanAudio);

cleanAudioF = fftshift(fft(cleanAudio))/samples;


figure
subplot(2,1,1)
plot(t, cleanAudio)
xlabel('Time (s)')
ylabel('Amplitude')
title('Clean Multiplexed Audio Signal in the Time Domain')
grid on

subplot(2,1,2)
plot(f, abs(cleanAudioF))
xlabel('Frequency (Hz)')
ylabel('Magnitude')
title('Clean Multiplexed Audio Signal in the Frequency Domain')
grid on

cleanDemodAudio = demodStreams(cleanAudio, carrierF, cutoffF, fs, 'Clean')

%% 1.5

noiseF = [2047 2467 2179 2079 2389];
frequencyBand = 20;

finalAudio = cell(1, length(cleanDemodAudio));

for k = 1:length(cleanDemodAudio)

    audioSignal = cleanDemodAudio{k};
    samplesSignal = length(audioSignal);

    signalF = linspace(-fs/2, fs/2, samplesSignal + 1);
    signalF(end) = [];

    audioSignalF = fftshift(fft(audioSignal));
    
    bins = abs(abs(signalF) - noiseF(k)) < frequencyBand;

    audioSignalF(bins) = 0

    finalAudio{k} = real(ifft(ifftshift(audioSignalF)));
    finalAudio{k} = finalAudio{k} - mean(finalAudio{k});

    finalAudioF = fftshift(fft(finalAudio{k})) / samplesSignal;

    figure
    subplot(2,1,1)
    plot((0:samplesSignal-1)/fs, finalAudio{k})
    xlabel('Time (s)')
    ylabel('Amplitude')
    title(['Fully De-noised Audio Signal, f_c = ', num2str(carrierF(k)), ' Hz'])    
    grid on

    subplot(2,1,2)
    plot(signalF, abs(finalAudioF))
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    title(['Fully De-noised Audio Spectrum, f_c = ', num2str(carrierF(k)), ' Hz'])    
    grid on
    xlim([-5000 5000])

    sound(finalAudio{k}, fs)
    pause(length(finalAudio{k})/fs + 1)

end

%% Functions
function demodAudio = demodStreams(inputAudio, carrierF, cutoffF, fs, labelName)
    inputAudio = inputAudio;
    samples = length(inputAudio);
    
    t = (0:samples-1)/fs;
    
    f = linspace(-fs/2, fs/2, samples +1);
    f(end) = [];


    for k = 1:length(carrierF)

        fc = carrierF(k);

        shift = inputAudio .* 2.*cos(2*pi*fc*t);
    
        demod = lowpass(shift, cutoffF, fs);
    
        demod = demod - mean(demod);
    
        demodAudio{k} = demod;
    
        demodf = fftshift(fft(demod))/samples;
    
    
        figure
        subplot(2,1,1)
        plot(t, demod)
        xlabel('Time (s)')
        ylabel('Amplitude')
        title([labelName, ' Demodulated Audio Signal, f_c = ', num2str(fc), ' Hz'])
        grid on
        
        subplot(2,1,2)
        plot(f, abs(demodf))
        xlabel('Frequency [Hz]')
        ylabel('Magnitude')
        title([labelName, ' Demodulated Audio Spectrum, f_c = ', num2str(fc), ' Hz'])
        grid on
        xlim([-5000 5000])

        sound(demod, fs)
        pause(length(demod)/fs + 1)
    
    end
end


