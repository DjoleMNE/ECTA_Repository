% Homework 3: SHAPE MATCHING PROBLEM
clear;clc;

%% Run experiment once
% Create a NACA foil
numEvalPts = 256;                           % Num evaluation points
nacaNum = [0, 0, 1, 2];                     % NACA Parameters
% nacaNum = [5, 5, 2, 2];                     % NACA Parameters 
% nacaNum = [9, 7, 3, 5];                     % NACA Parameters
nacafoil= create_naca(nacaNum, numEvalPts); % Create foil

% Perform evolution
output = shape_CMAES(rand(1), nacafoil, numEvalPts); % Run with hyperparameters
individual = output.best(:, end);
foil = output.best_foil(:, :, end);

% Visualize best shape
figure(1);
plot(nacafoil(1,:),nacafoil(2,:), 'LineWidth', 3);
hold on;
plot(foil(1,:),foil(2,:), 'r', 'LineWidth', 3);
axis equal;
axis([0 1 -0.7 0.7]);
legend('NACA 0012 target', 'Approximated Shape');
ax = gca;
ax.FontSize = 24;
drawnow;
hold off;
