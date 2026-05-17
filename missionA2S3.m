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