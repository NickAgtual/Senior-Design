clear; clc; close all
%% Material Properties
material.type = {'6061-T6', 'AISI 1005', 'Cast Acrylic'};

material.density = [2700 7872 1190]; % kg/m^3

material.poisson = [.325 .29 .37];

material.yield = [255 * 10^6, 285 * 10^6, 40 * 10^6] ; % Pa

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
        
        % Determining max radial stress for each case
        stress.rMax(ii, jj) = max(stress.r);
        
        % Tangential Stress
        stress.t = material.density(ii) * (w ^ 2) * ((3 + material.poisson(ii)) / 8) * ...
            ((disk.innerRadius ^2) + (disk.outerRadius(jj) ^ 2) - ...
            (((disk.innerRadius ^ 2) * (disk.outerRadius(jj) ^ 2)) ./ (r .^ 2)) - ...
            (r .^ 2));
        
        % Determining max tangential stress for each case
        stress.tMax(ii, jj) = max(stress.t);
        
    end
end


%% Radial and Tangential Stress Plot

% Creating figure for radial and tangential stress plot
figure(1)

% Plotting radial stress
plot(r .* 39.37, stress.r, 'DisplayName', 'Radial Stress');

% Plot parameters
hold on 
grid on
grid minor

% Plottign tangential stress
plot(r .* 39.37, stress.t, 'DisplayName', 'Tangential Stress')

% Plot descriptors
xlabel('\emph {Disk Diameter (in)}','fontsize',14,'Interpreter',...
    'latex');
ylabel('\emph {Stress (Pa)}','fontsize',14,'Interpreter','latex');
title('\emph {Stress in Rotating Disk}','fontsize',16,'Interpreter',...
    'latex')
legend('location', 'Best', 'Interpreter', 'latex')

% Ending plotting ability
hold off

%% FOS

% Solving for maximum stress for each combo of material and radius
stress.temp = cat(3, stress.rMax, stress.tMax);
stress.max = max(stress.temp, [], 3);

% Solving for all the FS and storing in a matrix
for ii = 1:length(material.density)
    for jj = 1:length(disk.outerRadius)
        stress.fs(ii, jj) =  material.yield(ii) / stress.max(ii, jj);
    end
end

% New figure for heat map plot
figure(2)

% Plotting heat map
heatMap = heatmap(cellstr(string(disk.outerRadius * 39.37)), ...
    material.type, stress.fs);

% Plot descriptors
heatMap.XLabel = '\emph {Outer Diameter (in)}';
heatMap.YLabel = '\emph {Material Type}';
heatMap.Title = 'FS Due to Stress in Rotating Disk';

% Editing descriptor font and size
heatMap.NodeChildren(3).XAxis.Label.Interpreter = 'latex';
heatMap.NodeChildren(3).XAxis.Label.FontSize = 13;
heatMap.NodeChildren(3).YAxis.Label.Interpreter = 'latex';
heatMap.NodeChildren(3).YAxis.Label.FontSize = 13;
heatMap.NodeChildren(3).Title.Interpreter = 'latex';
heatMap.NodeChildren(3).Title.FontSize = 15;







