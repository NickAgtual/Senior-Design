%% Stress In Rotating Disk
clear; clc; close all

% Conversion from inches to meters
inToMeter = (1 / 39.37);
%% Disk Parameters

% Disk material
disk.material = '6061 - T6 Aluminum';

% Thickness of disk
disk.thickness = .25 * inToMeter; % m

% Desnity of 6061-T6 aluminum
disk.density = 2700; % kg/m^3

% Poisson's ratio of 6061-T6 aluminum
disk.poisson = .325;

% Yield strength of 6061-T6 aluminum
disk.yield = 255 * 10^6; % Pa

% Disk inner radius
disk.innerRadius = 5/8; % in

% Disk outer radius
disk.outerRadius = 12; % in

% Converting radius values to meters
disk.innerRadius = disk.innerRadius * inToMeter;
disk.outerRadius = disk.outerRadius * inToMeter;

% Radii (variable)
r = disk.innerRadius:(.1 * inToMeter):disk.outerRadius(end);

% Angular velocity (Max stress occures at max angular velocity)
w = 3000; % rpm

% Converting to rad/s
w = w * 2 * pi / 60;

% Disk volume (m^3)
disk.volume = pi * ((disk.outerRadius .^ 2) - (disk.innerRadius ^2 )) ...
    * (disk.thickness);

% Weight of disk
disk.mass = disk.volume * disk.density; % kg

%% Loading on Disk

% Defining load names & magnitudes
load.names = {'Camera 1', 'Camera 2', 'Camera 3', 'Camera 3 Mount', ...
    'Weight Disk'};
load.magnitudes = [(.4922 / 2.205) (.4922/ 2.205) (.4922 / 2.205) ...
    (.3483 / 2.205) disk.mass];

% Assigning names to structure
for ii = 1:length(load.names)
    
    forces(ii).name = load.names{ii};
    
end

% Defining load coordinates (m)
forces(1).loadCoord = [-1.9375 -4.226 (disk.thickness / 2)] / 39.37;
forces(2).loadCoord = [2.852 0 (disk.thickness / 2)] / 39.37;
forces(3).loadCoord = [-1.9375 .7298 (disk.thickness / 2)] / 39.37;
forces(4).loadCoord = [-1.9 2.2267 (disk.thickness / 2)] / 39.37;
forces(5).loadCoord = [0 0 0];

% Defining loads
for ii = 1:length(load.magnitudes)
    
    % Load in (x,y,z) coordinate system
    forces(ii).loadMag = [0 0 -load.magnitudes(ii)];
    
end

%% Solving for Reaction Forces

% Defining symbolic variables
syms Ry

% Sum of forces in y-direction
summation.forcesY = 0 == Ry + forces(1).loadMag(3) + ...
    forces(2).loadMag(3) + forces(3).loadMag(3) + forces(4).loadMag(3) ...
    + forces(5).loadMag(3);

% Reaction force
Ry = double(solve(summation.forcesY, Ry));

%% Calculating Bending Moments

% Initializing bending moment matrix
M = zeros(1, 3, length(forces));

% Calclulating bending moment
% M = r x F
for ii = 1:length(forces)
    
    M(:, :, ii) = cross(forces(ii).loadCoord, forces(ii).loadMag);
    
end


%% Stress Due to Torsion

% Torque induced by motor (Nm)
T = 1.5;

% Calculating polar moment of intertia
J = (pi / 32) .* ((disk.outerRadius .^ 4) - (disk.innerRadius ^ 4));

% Calculating shear stress
stress.tau = T .* disk.outerRadius ./ J;

FS.torsion = disk.yield / stress.tau;

%% Bending Stress

% Initializing bending stress values
[stress.bendingX, stress.bendingY] = deal(0);

% Defining bending moment direction (x or y)
for ii = 1:length(M)
    
    % Bending stress about x-axis
    stress.bendingX = stress.bendingX + M(1, 1, ii);
    
    % Bending stress about y-axis
    stress.bendingY = stress.bendingY + M(1, 2, ii);
    
end

% Moment of inertia
I = (disk.mass / 2) * (((disk.outerRadius / 2) ^ 2 ) + ...
    ((disk.innerRadius / 2) ^ 2));

%% Stresses

% Radial Stress
stress.r = disk.density * (w ^ 2) * ...
    ((3 + disk.poisson) / 8) * ...
    ((disk.innerRadius ^ 2) + (disk.outerRadius ^ 2) + ...
    (((disk.innerRadius ^ 2) * (disk.outerRadius ^ 2)) ...
    ./ (r .^ 2)) - (((1 + (3 * disk.poisson)) / ...
    (3 + disk.poisson)) .* (r .^ 2)));

% Determining max radial stress 
stress.rMax = max(stress.r);

% Tangential Stress
stress.t = disk.density * (w ^ 2) * ...
    ((3 + disk.poisson) / 8) * ...
    ((disk.innerRadius ^2) + (disk.outerRadius ^ 2) - ...
    (((disk.innerRadius ^ 2) * (disk.outerRadius ^ 2)) ./...
    (r .^ 2)) - (r .^ 2));

% Determining max tangential stress 
stress.tMax = max(stress.t);

% Solving for maximum stress for each combo of material and radius
stress.temp = cat(3, stress.rMax, stress.tMax);
stress.max = max(stress.temp, [], 3);

% Solving for all the FS and storing in a matrix
FS.rotation =  disk.yield / stress.max;


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

%% Stress Tensor
    
% Creating stress tensors (plane-stress)
stress.stressTensor = [(stress.rMax + sum(stress.bendingX)) ...
    stress.tau 0; stress.tau (stress.tMax + sum(stress.bendingY)) 0; ...
    0 0 0];

% FS due to principal stresses
FS.principal = disk.yield ./ max(eig(stress.stressTensor));
