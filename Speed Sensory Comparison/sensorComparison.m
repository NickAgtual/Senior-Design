clear; clc; close all

%% Excel Descriptors
fileName = "Test Data.xlsm";
sheet.hallEffect = "Hall Effect Sensor";
sheet.IRProximity = "IR Proximity Sensor";
data.hallEffect = xlsread(fileName, sheet.hallEffect);
data.IRProximity = xlsread(fileName, sheet.IRProximity);

% Generating x-data
data.xAxis = 1:length(data.hallEffect);

%% Plotting
figure(1)

plot(data.xAxis(2808:end), data.hallEffect(2808:end),...
    'DisplayName', 'Hall Effect Sensor')
hold on
plot(data.xAxis(2808:end), data.IRProximity(2808:end),...
    'DisplayName', 'IR Proximity Sennsor')
grid on
grid minor

