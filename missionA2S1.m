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

% store the noisy multiplex signal and define key sampling and time
% variables
audio = audioMultiplexNoisy;
samples = length(audio);
ts = 1/fs;
T = samples/fs;

% create time and frequency vecotors for plotting 
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

% define the carrier frequencies and low-pass filter cutoff used for
% demodulation
carrierF = [72080 56030 40150 24290 8320];
cutoffF = 2000;

% demodulate the noisy multiplexed signal to recover each audio stream
demodAudio = demodStreams(audio, carrierF, cutoffF, fs, 'Noisy');



%% 1.3

% Generate a discrete impulse to measure the channel impulse response 
inputImpulse = [1/ts, zeros(1, samples-1)];

% pass the impulse throught the channel to obtain the impulse response
h = channel(sid, inputImpulse, fs);

% convert the noisy multiplexed audio into the frequency domain to find
% H(f)
H = fftshift(fft(h)) * ts;

% convert the audio into the frequency domain
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
% apply inverse filtering in the frequency domain to remove the channel
% effet
H = fft(h) * ts;
Y = fft(audio);

X = Y ./ H;

% converting the signal to the time domain and remove DC offset
cleanAudio = real(ifft(X));
cleanAudio = cleanAudio - mean(cleanAudio);

% convert to the frequency domain for plotting
cleanAudioF = fftshift(fft(cleanAudio))/samples;

% plot the cleaned multiplexed signal in the time and frequency domain
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

% demodulate the cleaned multiplexed signal to recover the individual
% streams
cleanDemodAudio = demodStreams(cleanAudio, carrierF, cutoffF, fs, 'Clean')

%% 1.5

% define the single-tone frequencies identified in the demodulated streams 
noiseF = [2047 2467 2179 2079 2389];
frequencyBand = 20;

% preallocating a cell array to store the de-noised audio streams
finalAudio = cell(1, length(cleanDemodAudio));

for k = 1:length(cleanDemodAudio)
    % select the current demodulated stream
    audioSignal = cleanDemodAudio{k};
    samplesSignal = length(audioSignal);
    
    % create a frequency vectore for the current stream
    signalF = linspace(-fs/2, fs/2, samplesSignal + 1);
    signalF(end) = [];

    audioSignalF = fftshift(fft(audioSignal));
    
    % identify frequency bins around the unwanted single-tone noise
    bins = abs(abs(signalF) - noiseF(k)) < frequencyBand;
    % remove the unwanted tone by setting those frequency components to 0
    audioSignalF(bins) = 0;
    
    % convert back to the time domain and reomve DC offset
    finalAudio{k} = real(ifft(ifftshift(audioSignalF)));
    finalAudio{k} = finalAudio{k} - mean(finalAudio{k});

    finalAudioF = fftshift(fft(finalAudio{k})) / samplesSignal;


    % plot the final de-noised audio stream in the time and frequency
    % domain
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
    % This function demodulates each carrier frequency by shifting the selected
    % stream to baseband, low-pass filtering it, and plotting the recovered
    % audio 

    inputAudio = inputAudio;
    samples = length(inputAudio);
    
    t = (0:samples-1)/fs;
    
    f = linspace(-fs/2, fs/2, samples +1);
    f(end) = [];

    % repeat the process for each carrier frequency
    for k = 1:length(carrierF)

        fc = carrierF(k);
        
        % shift the selected carrier signal down to baseband
        shift = inputAudio .* 2.*cos(2*pi*fc*t);
        
        % apply a low-pass filter to isolate the audio component
        demod = lowpass(shift, cutoffF, fs);
    
        demod = demod - mean(demod);
        
        % store the recovered audio stream
        demodAudio{k} = demod;
    
        demodf = fftshift(fft(demod))/samples;
    
        % plot the demodulated streams in the frequency and time domains
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


