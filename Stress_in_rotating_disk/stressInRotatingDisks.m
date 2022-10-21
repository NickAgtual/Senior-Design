clear; clc; close all
%% Material Properties
% [6061-T6, AISI 1005, 

material.density = [2700 7872]; % kg/m^3

material.poisson = [.325 .29];

material.yield = [255 * 10^6, 285 * 10^6] ; % Pa

%% Disk Properties

disk.innerRadius = 5/8; % in

disk.outerRadius = 8:10; % in

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

for ii = 1:length(material.density)
    for jj = 1:length(disk.outerRadius)
        
        % Radial Stress
        stress.r = material.density(ii) * (w ^ 2) * ((3 + material.poisson(ii)) / 8) * ...
            ((disk.innerRadius ^ 2) + (disk.outerRadius(jj) ^ 2) + ...
            (((disk.innerRadius ^ 2) * (disk.outerRadius(jj) ^ 2)) ./ (r .^ 2)) - ...
            (((1 + (3 * material.poisson(ii))) / (3 + material.poisson(ii))) .* (r .^ 2)));
        
        stress.rMax(ii, jj) = max(stress.r);
        
        
        % Tangential Stress
        stress.t = material.density(ii) * (w ^ 2) * ((3 + material.poisson(ii)) / 8) * ...
            ((disk.innerRadius ^2) + (disk.outerRadius(jj) ^ 2) - ...
            (((disk.innerRadius ^ 2) * (disk.outerRadius(jj) ^ 2)) ./ (r .^ 2)) - ...
            (r .^ 2));
        
        stress.tMax(ii, jj) = max(stress.t);
        
    end
end


%% Radial and Tangential Stress Plot

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

hold off

%% FOS

stress.temp = cat(3, stress.rMax, stress.tMax);
stress.max = max(stress.temp, [], 3);

for ii = 1:length(material.density)
    for jj = 1:length(disk.outerRadius)
        stress.fs(ii, jj) =  material.yield(ii) / stress.max(ii, jj);
    end
end


figure(2)

heatMap = heatmap(stress.fs)




