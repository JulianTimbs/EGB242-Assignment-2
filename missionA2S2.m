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

% Variable definitions
T = 25;
samples = 1e4;
fs = samples / T;
ts = 1 / fs;

% Time vector
timeVec = linspace(0, T, samples + 1);
timeVec(end) = [];

% Input step
inputStep = ones(size(timeVec));

% Transfer function
num1 = [1];
den1 = [1, 0.5, 0];
H1 = tf(num1, den1);

% Impulse response
g_m = 2 * (1 - exp(-0.5 * timeVec));

% Step Response using lsim()
stepResponse = lsim(H1, inputStep, timeVec);

% Step response plot
figure;
plot(timeVec, stepResponse);
hold on;
plot(timeVec, inputStep);

title("Step Response of DC Motor");
xlabel("Time [s]");
ylabel("Rotation [rad]");
legend("Step Response", "Input Step");
% plot diverges -> inf so motor alone isn't sufficient to control camera