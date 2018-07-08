%% Enforced Sub-Populations Method
function weight_matrix = esp(p)
% clc;
% clear;
% p.bothPoles = false;
% p.bias_included = false;
% p.visualize = false;
% p.num_hidden = 10;
% p.output_size = 1;
% p.num_trials = 10;
% p.subPop_size = 20;
% p.num_generations = 1;

if p.bothPoles 
    p.input_size = 6;
else
    p.input_size = 4;
end

if p.bias_included
    p.input_size = p.input_size + 1;
end
p.chromo_size = p.input_size + p.output_size;
p.net_size      = p.input_size + p.num_hidden + p.output_size;

%% Initialize data struct
hidden_node = struct('individual', ...
                      repmat({struct('chromosome',...
                                     repmat({zeros(1, p.chromo_size)},...
                                             p.subPop_size, 1),...
                                     'participation_count', 0, ...
                                     'cum_fitness', 0)},...
                              p.num_hidden, 1));

%% Initialize weights/subpopulations
for node = 1:p.num_hidden
    for index = 1:p.subPop_size        
        hidden_node(node).individual(index).chromosome = rand(1 , p.chromo_size);       
    end
end
weight_matrix = zeros(p.net_size);

%% Perform evolution
for step = 1:p.num_generations
    %Generate random index of an individual and save it in vector
    chosen_individuals = randi(p.subPop_size, [1, p.num_hidden]);
    
    % Form a random NN
    for node = 1:p.num_hidden        
        weight_matrix(1:p.input_size, p.input_size + node)=...
                      hidden_node(node).individual(chosen_individuals(node)).chromosome(1:p.input_size);      
        weight_matrix(p.input_size + node,...
                      p.input_size + p.num_hidden + 1 : end)=...
                      hidden_node(node).individual(chosen_individuals(node)).chromosome(p.input_size + 1:end);
        hidden_node(node).individual(chosen_individuals(node)).participation_count =...
           hidden_node(node).individual(chosen_individuals(node)).participation_count +1;        
    end
    
    % Perform the simulation and evaluate the choosen NN
    fitness = twoPoleDemo(p, weight_matrix);
    for node = 1:p.num_hidden
        hidden_node(node).individual(chosen_individuals(node)).cum_fitness =...
           hidden_node(node).individual(chosen_individuals(node)).cum_fitness + fitness;  
    end
    disp(fitness)
    
end
