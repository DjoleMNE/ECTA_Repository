%% Perform cartPole experiment using ESP method - Main file
%% Setting hyperparameters
clc;
clear;
p.bothPoles         = true;
p.recurrent_nn      = true;
p.bias_included     = false;
p.velocity_inclued  = false;
p.visualize         = false;
p.num_hidden        = 5;
p.mutProb           = 0.4;
p.output_size       = 1;
p.num_trials        = 10;
p.static_limit      = 20;
p.subPop_size       = 40;
p.total_individuals = p.num_hidden * p.subPop_size;
p.num_generations   = 500;
p.goal_fitness      = 1000;

if p.bothPoles
    p.input_size = 6;
else
    p.input_size = 4;
end

if ~p.velocity_inclued
    p.input_size = p.input_size/2;
end

if p.bias_included
    p.input_size = p.input_size + 1;
end

p.chromo_size   = p.input_size + p.output_size;
p.net_size      = p.input_size + p.num_hidden + p.output_size;

%% Performing the experiment
best_matrix = esp(p);
p.visualize = true;
if p.bothPoles
    save('best_matrix_dpoles.mat', 'best_matrix');
else
    save('best_matrix_spole.mat', 'best_matrix');
end
disp("Final simulation started")
% Perform the simulation and evaluate the choosen NN
fitness = twoPoleDemo(p, best_matrix);
disp(fitness)