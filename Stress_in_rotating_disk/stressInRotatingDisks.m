clear; clc; close all

%% Environmental properties
gravity = 9.81; % m/s^2

%% Material Properties
material.type = {'6061-T6', 'A36 Steel', 'Cast Acrylic'};

material.density = [2700 7800 1190]; % kg/m^3

material.poisson = [.325 .26 .37];

material.yield = [255 * 10^6, 250 * 10^6, 40 * 10^6] ; % Pa

%% Disk Properties

disk.innerRadius = 5/8; % in

disk.outerRadius = 8:16; % in

% Converting to meters
disk.innerRadius = disk.innerRadius / 39.37;

disk.outerRadius = disk.outerRadius / 39.37;

% Radii
r = disk.innerRadius:(.1/39.37):disk.outerRadius(end);

% Angular velocity (Max stress occures at max angular velocity)
w = 3000;

% Converting to rad/s
w = w * 2 * pi / 60;

% Accesory Compoents Weight 
disk.accessoryCompW = 1; % lbf

% Disk thickness
disk.thickness = 1/8; % in

% Converting to meters
disk.thickness = disk.thickness / 39.37;

% Disk volume (m^3)
disk.volume = pi * ((disk.outerRadius .^ 2) - (disk.innerRadius ^2 )) ...
    * (disk.thickness);

% Disk weight
for ii = 1:length(material.type)
    for jj = 1:length(disk.outerRadius)
        disk.weight(ii, jj) = material.density(ii) * disk.volume(jj) * ...
            gravity;
    end
end

%% Motor Properties
hp = 1;

%% Stresses

for ii = 1:length(material.type)
    for jj = 1:length(disk.outerRadius)
        
        % Radial Stress
        stress.r = material.density(ii) * (w ^ 2) * ...
            ((3 + material.poisson(ii)) / 8) * ...
            ((disk.innerRadius ^ 2) + (disk.outerRadius(jj) ^ 2) + ...
            (((disk.innerRadius ^ 2) * (disk.outerRadius(jj) ^ 2)) ...
            ./ (r .^ 2)) - (((1 + (3 * material.poisson(ii))) / ...
            (3 + material.poisson(ii))) .* (r .^ 2)));
        
        % Determining max radial stress for each case
        stress.rMax(ii, jj) = max(stress.r);
        
        % Tangential Stress
        stress.t = material.density(ii) * (w ^ 2) * ...
            ((3 + material.poisson(ii)) / 8) * ...
            ((disk.innerRadius ^2) + (disk.outerRadius(jj) ^ 2) - ...
            (((disk.innerRadius ^ 2) * (disk.outerRadius(jj) ^ 2)) ./...
            (r .^ 2)) - (r .^ 2));
        
        % Determining max tangential stress for each case
        stress.tMax(ii, jj) = max(stress.t);
        
    end
end

% Solving for maximum stress for each combo of material and radius
stress.temp = cat(3, stress.rMax, stress.tMax);
stress.max = max(stress.temp, [], 3);

% Solving for all the FS and storing in a matrix
for ii = 1:length(material.type)
    for jj = 1:length(disk.outerRadius)
        FS.rotation(ii, jj) =  material.yield(ii) / stress.max(ii, jj);
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

%% Stress Due to Torsion

% Torque induced by motor (Nm)
T = (hp * 5252 / w) * 1.35582;

% Calculating polar moment of intertia
J = (pi / 32) .* ((disk.outerRadius .^ 4) - (disk.innerRadius ^ 4));

% Calculating shear stress
tau = T .* disk.outerRadius ./ J;

% Initializing FS matrix due to torison
FS.torsion = zeros(length(material.density), length(disk.outerRadius));

% FS due to torsion
for ii = 1:length(material.type)
    for jj = 1: length(tau)
        
        FS.torsion(ii, jj) = material.yield(ii) / tau(jj);
        
    end
end

%% Bending Stress

% Defining symbolic variables
syms Ry

% Sum of forces - y
sum.forcesY = -(2 * disk.accessoryCompW) - disk.weight + (2 * Ry) == 0;

% Sum of moments about left most edge
sum.moments = (disk.outerRadius .* Ry) - ...
              (disk.weight ./ disk.outerRadius) - ...
              (disk.outerRadius .* disk.accessoryCompW) == 0;

% Bending moment
M = disk.accessoryCompW * 4.44822 .* (disk.outerRadius ./ 2);

% Moment of inertia
I = (1/12) .* disk.outerRadius * (disk.thickness ^ 3);

% Stress due to bending
stress.bending = M * (disk.thickness / 2) ./ I;

%% Stress Tensor
% Initializing FS matrix for principal stresses
FS.principal = zeros(length(material.density), length(disk.outerRadius));

for ii = 1:length(material.type)
    for jj = 1:length(disk.outerRadius)
        
        % Creating stress tensors (plane-stress)
        stressTensor = [(stress.rMax(ii, jj) + stress.bending(jj)) ...
            tau(1, jj) 0; tau(1, jj) stress.tMax(ii, jj) 0; 0 0 0];
        
        % FS due to principal stresses
        FS.principal(ii, jj) = material.yield(ii) ./ ...
            max(eig(stressTensor));
    end
end

%% FS Heat Map
% New figure for heat map plot
figure(2)

% Plotting heat map
heatMap = heatmap(cellstr(string(disk.outerRadius * 39.37)), ...
    material.type, FS.principal);

% Plot descriptors
heatMap.XLabel = '\emph {Outer Diameter (in)}';
heatMap.YLabel = '\emph {Material Type}';
heatMap.Title = '\emph {Safety Factor of Rotating Disk}';

% Editing descriptor font and size
heatMap.NodeChildren(3).XAxis.Label.Interpreter = 'latex';
heatMap.NodeChildren(3).XAxis.Label.FontSize = 13;
heatMap.NodeChildren(3).YAxis.Label.Interpreter = 'latex';
heatMap.NodeChildren(3).YAxis.Label.FontSize = 13;
heatMap.NodeChildren(3).Title.Interpreter = 'latex';
heatMap.NodeChildren(3).Title.FontSize = 15;
            
            