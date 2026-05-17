%%%% EGB242 Assignment 2, Section 3 %%
% This file is a template for your MATLAB solution to Section 3.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;
load DataA2 imagesReceived;

% Begin writing your MATLAB solution below this line.

%% 3.1 
% Display the first received landing site image that has been received from the communication
% channel and comment on the image quality.

numRows = 480;
numCols = 640;

im1_2D = reshape(imagesReceived(1,:), numRows, numCols);

figure;
imshow(im1_2D);

% Save image 1 matrix as an image file
%%%%%%%%%% UNCOMMENT TO SAVE %%%%%%%%%%%%%%
% imwrite(im2D, 'unfilteredImage.png');

%% 3.2
% Construct a time and frequency vector for the received signal and store these in
% t and f, respectively
% Visualise the received signal in both the time and frequency domains.

% Time vector
T = (numRows * numCols) / 1000;
samples = numRows * numCols;

t = linspace(0, T, samples + 1);
t(end) = [];

% Frequency Vector
fs = samples / T;

f = linspace(-fs/2, fs/2, samples + 1);
f(end) = [];

% Fourier tranform of image signal
% To access each image use image = n -> im_freq(n,:)
im_freq = fft(imagesReceived, [], 2) / fs;

% Time domain plot of images
figure;
for i = 1:4
    subplot(2, 2, i);
    plot(t, imagesReceived(i,:));
    title(sprintf('Time Domain Plot - Image %d', i))
    xlabel("Time [s]");
    ylabel("Amplitude");
end

% Frequency domain (mag & phase spectrum) plot of image
for i = 1:4
    figure;
    subplot(2, 1, 1);
    plot(f, fftshift(abs(im_freq(i,:))));
    title(sprintf('Magnitude Spectrum - Image %d', i));
    xlabel("Frequency [Hz]");
    ylabel("Amplitude");
    subplot(2, 1, 2);
    plot(f, unwrap(fftshift(angle(im_freq(i,:)))));
    title(sprintf('Phase Spectrum - Image %d', i));
    xlabel("Frequency [Hz]");
    ylabel("Phase [rad]");
end

%% 3.3
% Looking for low-pass filter ~50 Hz cut-off I think

% Circuit element variables
R = 820;
C = 1e-6;
R1 = 1200;
R2 = 1000;
C1 = 10e-6;
C2 = 4.7e-6;

% Passive filter 1 transfer function
pFilter1_num = [1/R2*C2, 0];
pFilter1_den = [1, (C2*R1 + C1*R1 + R2*C2)/(R2*R1*C1*C2), 1/(R2*R1*C1*C2)];

pFilter1_TF = tf(pFilter1_num, pFilter1_den);

% Passive filter 2 transfer function
pFilter2_num = [1/(C1*C2*R1*R2)];
pFilter2_den = [1, (C2*R1 + C2*R2 + C1*R1)/(C1*C2*R1*R2), 1/(C1*C2*R2*R1)];

pFilter2_TF = tf(pFilter2_num, pFilter2_den);


% Active filters  

% active filter 1 transfer function
aFilter1_num = [1, 0, 0];
aFilter1_den = [1, 2/(R*C), 1/(R*C)^2];

aFilter1_TF = tf(aFilter1_num, aFilter1_den);


% Active filter 2 transfer function
aFilter2_num = [1/(R*C)^2];
aFilter2_den = [1, 2/(R*C), 1/(R*C)^2];

aFilter2_TF = tf(aFilter2_num, aFilter2_den);

% comparison using bode plot

f_response = linspace(0, fs/2, 2000);
w_response = 2*pi*f_response;

aFilter1_mag = squeeze(abs(freqresp(aFilter1_TF, w_response)));
aFilter2_mag = squeeze(abs(freqresp(aFilter2_TF, w_response)));

figure;
plot(f_response, aFilter1_mag);
hold on;
plot(f_response, aFilter2_mag);
xlabel('Frequency [Hz]');
ylabel('Magnitude');
title('Frequency Response of Active Filters');
legend('Active Filter 1', 'Active Filter 2');
grid on;

fc_active2 = 125;

im1_signal = imagesReceived(1,:);
im1_freq = fftshift(fft(im1_signal)) / samples;


%% 3.4

% using the chosen filter (active filter 2) to remove the recieved signal 

im1_signal = imagesReceived(1,:).';   % make column vector for lsim
t_col = t.';                          % make time vector column

% Apply Active Filter 2
clean_signal = lsim(aFilter2_TF, im1_signal, t_col);

% Convert the filtered signal back into an image
clean_image = reshape(clean_signal, numRows, numCols);

% Display original and cleaned image
figure;
imshow(clean_image);
title('Cleaned Image using Active Filter 2');

% visualise the clean image signal in the time domain
figure;
plot(t, clean_signal);
xlabel('Time [s]');
ylabel('Pixel Intensity');
title('Cleaned Image Signal in the Time Domain');
grid on;

% visualise the clean image signal in the frequency domain

clean_freq = fft(clean_signal) / samples;

figure
subplot(2, 1, 1);
plot(f, fftshift(abs(clean_freq)));
title('Magnitude Spectrum - Cleaned Image');
xlabel("Frequency [Hz]");
ylabel("Amplitude");
grid on;

subplot(2, 1, 2);
plot(f, unwrap(fftshift(angle(clean_freq))));
title('Phase Spectrum - Cleaned Image');
xlabel("Frequency [Hz]");
ylabel("Phase [rad]");
grid on;

%% 3.5

% Repeat the de-noising process for all recieved images using active filter
% 2

numImages = size(imagesReceived, 1);
cleanImages = cell(1, numImages);

figure;

for i = 1:numImages

    % Get received image signal
    image_signal = imagesReceived(i,:).';

    clean_signal = lsim(aFilter2_TF, image_signal, t_col);

    clean_image = reshape(clean_signal, numRows, numCols);

    % Store clean image
    cleanImages{i} = clean_image;

    % Display clean image
    subplot(2, 2, i);
    imshow(clean_image);
    title(sprintf('Cleaned Landing Site Image %d', i));

end

