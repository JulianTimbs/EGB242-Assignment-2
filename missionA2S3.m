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