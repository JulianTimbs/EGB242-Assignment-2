%% EGB242 Assignment 2, Section 2 %%
% This file is a template for your MATLAB solution to Section 2.
%
% Before starting to write code, generate your data with the ??? as
% described in the assignment task.

%% Initialise workspace
clear all; close all;

% Begin writing your MATLAB solution below this line.
%% 2.1
% Plot comparison between the step input and the step response
% g_m(t) = 2(1 - e^-0.5t)

% Time vector
T = 25;
samples = 1e4;
timeVec = linspace(0, T, samples + 1);
timeVec(end) = [];

% Impulse response
g_m = 2 * (1 - exp(0.5* timeVec));

% Step response -> G_m(s) * 1/s
g_step = 2 * (timeVec - 2 + 2*exp(-0.5 * timeVec));


