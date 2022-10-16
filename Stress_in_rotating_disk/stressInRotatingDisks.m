clear; clc; close all
%% Material Properties

material.density = 2700;

material.poisson = .325;

material.yield = 276 * 10^6; % Pa

%% Disk Properties

disk.innerRadius = 5/8; % in

disk.outerRadius = 9; % in

% Converting to meters
disk.innerRadius = disk.innerRadius / 39.37;

disk.outerRadius = disk.outerRadius / 39.37;

% Radii
r = disk.innerRadius:(.1/39.37):disk.outerRadius;

% Angular velocity (Max stress occures at max angular velocity)
w = 3000;

% Converting to rad/s
w = w * 2 * pi / 60;

%% Stresses

% Radial Stress
stress.r = material.density * (w ^ 2) * ((3 + material.poisson) / 8) * ...
    ((disk.innerRadius ^ 2) + (disk.outerRadius ^ 2) + ...
    (((disk.innerRadius ^ 2) * (disk.outerRadius ^ 2)) ./ (r .^ 2)) - ...
    (((1 + (3 * material.poisson)) / (3 + material.poisson)) .* (r .^ 2)));

% Tangential Stress
stress.t = material.density * (w ^ 2) * ((3 + material.poisson) / 8) * ...
    ((disk.innerRadius ^2) + (disk.outerRadius ^ 2) - ...
    (((disk.innerRadius ^ 2) * (disk.outerRadius ^ 2)) ./ (r .^ 2)) - ...
    (r .^ 2));


%% Plots

figure(1)

plot(r .* 39.37, stress.r, 'DisplayName', 'Radial Stress');

hold on 
grid on
grid minor

plot(r .* 39.37, stress.t, 'DisplayName', 'Tangential Stress')

xlabel('\emph {Disk Diameter (in)}','fontsize',14,'Interpreter',...
    'latex');
ylabel('\emph {Stress (Pa)}','fontsize',14,'Interpreter','latex');
title('\emph {Stress in Rotating Disk}','fontsize',16,'Interpreter',...
    'latex')
legend('location', 'Best', 'Interpreter', 'latex')

%% FOS

stress.max = max([stress.r stress.t]); % Pa

fsMin = material.yield / stress.max;



