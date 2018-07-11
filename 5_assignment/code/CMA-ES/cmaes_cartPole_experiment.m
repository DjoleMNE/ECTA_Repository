%% Perform cartPole experiment using CMA-ES method - Main file
%% Setting hyperparameters
clc;
clear;
p.bothPoles          = true;
p.recurrent_nn       = false;
p.velocity_inclued   = false;
p.visualize          = false;
p.num_hidden         = 3;
p.output_size        = 1;
p.num_generations    = 700;
p.goal_fitness       = 1000;

if p.bothPoles
    p.input_size = 6;
else
    p.input_size = 4;
end

if ~p.velocity_inclued
    p.input_size = p.input_size/2;
end

p.net_size          = p.input_size + p.num_hidden + p.output_size;
p.num_open          = p.input_size + p.output_size;

if p.recurrent_nn
    p.chromo_size   = p.net_size * p.num_open;    
else
    p.chromo_size   = p.num_hidden * p.num_open;
end

%% Performing the experiment
output = cartPole_CMA_EP_ES(p);
solution = output.fitMax;
disp("Solution:  " + solution);
best_matrix = output.best_matrix;

if output.solution_found
    p.visualize = true;
    
    if p.bothPoles
        if p.velocity_inclued
            save('best_matrix_dpoles.mat', 'best_matrix');
        else
            save('best_matrix_dpoles_no_vel.mat', 'best_matrix');
        end
    else
        if p.velocity_inclued
            save('best_matrix_spole.mat', 'best_matrix');
        else
            save('best_matrix_spole_no_vel.mat', 'best_matrix');
        end
    end
    disp("Final simulation started")
    % Perform the simulation and evaluate the choosen NN
    clf;
    fitness = cmaes_twoPoleDemo(p, output.best_matrix);
    disp("Score: " + fitness)
end

% fitness_values = output.fitMax;
% figure(2); clf; hold on;
% eval = 6:6:9996;
% plot(eval, fitness_values);
% set(gca,'YScale','log')
% legend('Min Fitness','Location','NorthWest');
% xlabel('Function evaluations'); ylabel('Fitness value');
% set(gca,'FontSize',16);
% title('Performance')