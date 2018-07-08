%% Perform cartPole experiment using ESP method - Main file
%% Setting hyperparameters
clc;
clear;
p.bothPoles = false;
p.bias_included = false;
p.visualize = false;
p.num_hidden = 10;
p.output_size = 1;
p.num_trials = 10;
p.subPop_size = 20;
p.num_generations = 1;


%% Performing experiment
weight_matrix = esp(p);