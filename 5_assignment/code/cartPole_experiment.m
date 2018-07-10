%% Perform cartPole experiment using ESP method - Main file
%% Setting hyperparameters
clc;
clear;
p.bothPoles          = true;
p.recurrent_nn       = true;
p.bias_included      = false;
p.velocity_inclued   = true;
p.visualize          = false;
p.use_burst_mutation = true;
p.num_hidden         = 5;
p.mutProb            = 0.4;
p.output_size        = 1;
p.num_trials         = 10;
p.subPop_size        = 40;
p.num_generations    = 500;
p.goal_fitness       = 1000;
if p.use_burst_mutation
    p.static_limit   = 20;
else
    p.static_limit   = p.num_generations;
end

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

p.net_size          = p.input_size + p.num_hidden + p.output_size;

if p.recurrent_nn
    p.chromo_size   = p.net_size * (p.num_hidden + p.output_size);    
else
    p.chromo_size   = p.input_size + p.output_size;
end

%% Performing the experiment
[best_matrix, solution_found] = esp(p);
if solution_found
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
    fitness = twoPoleDemo(p, best_matrix);
    disp(fitness)
end