clear; clc; close all;

% Importing hall effect data from Excel
excelData = 'Speed Sensor Data';
vData = xlsread(excelData);

% Defining time data
time = linspace(0, 21, 21);

% Defining symbolic variable
syms t

% Defining piecewise function
v = piecewise(t < 0, 0, ...
    (0 < t) & (t < 10), (60 * t), ...
    (10 < t) & (t < 15), 600);

% Creating new figure
figure(1)

% Plotting piecewise function
fplot(v)

hold on

tt = linspace(1, 15, 2857);
plot(tt, vData(:, 3))


% Setting plot parameters
xlim([0, 13])
ylim([-25, 650]);
grid on;
grid minor;
 
% Plot descriptors
title('\emph{Velocity Profile}', 'fontsize', ...
    16, 'Interpreter', 'Latex')
xlabel('\emph{t [sec]}', 'fontsize', 14, 'Interpreter', 'Latex')
ylabel('\emph{Angular Velocity [RPM]}',...
    'fontsize', 14, 'Interpreter', 'Latex')
legend('Desired Velocity Profile' ,'Speed Sensor Data', 'location', ...
    'northwest', 'interpreter', 'latex')
