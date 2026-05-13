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

% Impulse response
g_m = 2 * (1 - exp(-0.5 * timeVec));

% Step Response from hand working
g_step = -4 + 2 * timeVec + 4 * exp(-0.5 * timeVec);

% Step response plot
figure;
plot(timeVec, g_step);
hold on;
plot(timeVec, inputStep);
title("Step Response of DC Motor");
xlabel("Time [s]");
ylabel("Rotation [rad]"); %TODO: Put proper ylabel
legend("Step Response", "Input Step");
% plot diverges -> inf so motor alone isn't sufficient to control camera

%% 2.2 
% Supervisor's suggestion is justified

%% 2.3

num = 1;
den = [1, 0.5, 1];

F = tf(num, den);

F_step = lsim(F, inputStep, timeVec);
figure;
plot(timeVec, F_step);
hold on;
plot(timeVec, inputStep);
title("Step Response of DC Motor with Potentiometer");
xlabel("Time [s]");
ylabel("Rotation [rad]"); %TODO: Put proper ylabel
legend("Step Response", "Input Step");
% System converges now (under-damped)

%% 2.4

% I think maybe need to wait for week 11 lecture??
% w_n = 1, zeta = 0.25
% Still not appropriate for controlling camera displacement because of
% massive overshoot

%% 2.5
% TF = K_fwd / (s^2 + 0.5s + K_fwd * K_fb)

Kfwd_values = [0.1, 0.2, 0.5, 1, 2];
Kfb_values = [0.1, 0.2, 0.5, 1, 2];

legendEntries_fb = cell(1, length(Kfb_values));

figure;
for i = 1:length(Kfb_values)
    K_fb = Kfb_values(i);
    num2 = 1;
    den2 = [1, 0.5, K_fb];
    F_gain = tf(num2, den2);
    F_gain_step = lsim(F_gain, inputStep, timeVec);
    plot(timeVec, F_gain_step);
    hold on;
    legendEntries_fb{i} = sprintf('K_{fb} = %.1f', K_fb);
end
legend(legendEntries_fb);
hold off;
title("Step Response of DC Motor System with Feedback Gain");
xlabel("Time [s]");
ylabel("Rotation [rad]"); %TODO: Put proper ylabel
legend(legendEntries_fb);

legendEntries_fwd = cell(1, length(Kfwd_values));

figure;
for i = 1:length(Kfwd_values)
    K_fwd = Kfwd_values(i);
    num3 = K_fwd;
    den3 = [1, 0.5, K_fwd];
    F_gain = tf(num3, den3);
    F_gain_step = lsim(F_gain, inputStep, timeVec);
    plot(timeVec, F_gain_step);
    hold on;
    legendEntries_fwd{i} = sprintf('K_{fwd} = %.1f', K_fwd);
end
legend(legendEntries_fwd);
hold off;
title("Step Response of DC Motor System with Forward Gain");
xlabel("Time [s]");
ylabel("Rotation [rad]"); %TODO: Put proper ylabel
legend(legendEntries_fwd);