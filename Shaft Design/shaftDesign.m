clear; clc; close all

%% Input Parameters

% Motor power
P = 1; % HP

% Max angular speed
omega = 3000; % RPM

% Weight of disk
weightDisk = 1; % lbf

% Weight of pulley
weightPulley = 1; % lbf

% Gravity
g = 32.17; % ft/s^2

% Coeff. of Friction (Belt and pulley)
mu = 1; % lbf

% V-belt angle
beta = 1; % Degrees

% Motor pulley diameter
motorPulley = 1; % ft

% Shaft pulley diameter
shaftPulley = 1; % ft

% Shaft Dimensions
% From base to pulley
lf = 1; % ft

% From base tp supprting bearing
lBearing = 2; % ft

% From base to disk
lShaft = 4; % ft


%% Calculations

% Transmitted torque
tau = P / omega;

% Angle of wrap (CALCULATE)
theta = 1;

% Apparent coeff. of friction
mue = mu / sind(beta); % lbf

% Ratio of tension
ratTens = exp(mue * theta);

% Solving for belt forces
% Fb1 - Fb2 = tau / r
% Fb1/Fb2 = ratTens
Fb2 = (tau / (shaftPulley / 2)) / (ratTens - 1);
Fb1 = Fb2 * ratTens;

% Pulley force vector
Fp = (Fb1 + Fb2) * cosd(theta - 180);

% Equilibrium equations
syms RAx RCx RAy

% Sum forces x
sumFx = 0 == RAx + Fp +RCx;

% Sum forces y
sumFy = 0 == -weightDisk - weightPulley + RAy;

% Sum of moments about A
sumMomentsA = 0 == (-Fp * lf) - (RCx * lBearing);

% Converting equations to matrix form
[A, b] = equationsToMatrix([sumFx sumFy sumMomentsA], [RAx RCx RAy]);

% Solving linear system of equations
vals = linsolve(A, b);

% Assigning solved forces to variables
RAx = vals(1);
RCx = vals(2);
RAy = vals(3);

%% Shear and Bending Moment Diagrams

syms y

% Shear
shear = piecewise(y < 0, 0, ...
                      0 < y < lf, RAx, ...
                      lf < y < lBearing, RAx + Fp, ...
                      lBearing < y < lShaft, RAx + Fp + RCx, ...
                      y > lShaft, 0);
                 
                  
shearPlot = fplot(shear); 
shearPlot.ShowPoles = 'Off';
hold on
grid on
grid minor

% Piecewise function for appearance (no line below 0 and greater than
% length)
white = piecewise(y < 0, 0, y > lShaft, 0);

% Plotting while lines
whitePlot = fplot(white, 'Color', [1 1 1]);

% Turning asymptotes off
whitePlot.ShowPoles = 'Off';

% Plotting y = 0
yline(0, 'k')

% Setting axis limits
xlim([-.25 lShaft + .25]);
ylim([double((RAx + Fp)) - .0001, double(RAx) + .0001]);

% Axis Descriptors
xlabel('\emph {y - distance (in)}', ...
    'fontsize', 12, 'Interpreter', 'latex');
ylabel('\emph {V (lbf)}', 'fontsize', 12, 'Interpreter', 'latex');
title('\emph {Shear Diagram}', 'fontsize', ...
14, 'Interpreter', 'latex');






