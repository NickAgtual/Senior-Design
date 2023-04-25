clear; close all; clc

velocity.target = 100:100:1000;
velocity.actual = [99 198 296 397 492 582 688 777 877 952];

velocity.barData = reshape([velocity.target velocity.actual], ...
[length(velocity.actual), 2]);

figure(1)
bar(velocity.barData)
grid on
grid minor
