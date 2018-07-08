%% Perform cartPole experiment using ESP method - Main file
%% Setting hyperparameters
clc;
clear;
p.bothPoles = false;
p.bias_included = false;
p.visualize = false;
p.num_hidden = 8;
p.mutProb = 0.4;
p.output_size = 1;
p.num_trials = 10;
p.subPop_size = 10;
p.total_individuals = p.num_hidden * p.subPop_size;
p.num_generations = 30;

if p.bothPoles 
    p.input_size = 6;
else
    p.input_size = 4;
end

if p.bias_included
    p.input_size = p.input_size + 1;
end
p.chromo_size   = p.input_size + p.output_size;
p.net_size      = p.input_size + p.num_hidden + p.output_size;

%% Performing experiment
best_matrix = esp(p);
p.visualize = true;
save('best_matrix.mat','best_matrix');

% Perform the simulation and evaluate the choosen NN
fitness = twoPoleDemo(p, best_matrix);

disp(fitness)