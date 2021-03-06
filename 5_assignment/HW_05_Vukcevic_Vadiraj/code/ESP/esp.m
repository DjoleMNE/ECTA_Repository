%% Enforced Sub-Populations Method
function [best_matrix, solution_found] = esp(p)
%% Setting parameters
solution_found = true;
if p.recurrent_nn
    hidden_length = p.num_hidden + p.output_size;
else
    hidden_length = p.num_hidden;
end

%% Initialize data struct
hidden_node = struct('individual', ...
                      repmat({struct('chromosome',...
                                     repmat({zeros(1, p.chromo_size)},...
                                             p.subPop_size, 1),...
                                     'participation_count', 0, ...
                                     'cum_fitness', 0)},...
                              hidden_length, 1));

%% Initialize weights/subpopulations
for node = 1:hidden_length
    for index = 1:p.subPop_size        
        hidden_node(node).individual(index).chromosome = rand(1 , p.chromo_size);       
    end
end
weight_matrix = zeros(p.net_size);
for index = 1:p.input_size
    weight_matrix(index, index) = 1;
end
best_matrix   = weight_matrix;
best_fitness  = 0;
static_generations = 0;
overall_best_fitness = 0;
best_individuals = randi(p.subPop_size, [1, hidden_length]);
final_step = 0;
best_nodes = hidden_node;

%% Perform evolution
for step = 1:p.num_generations
    final_step = step; 
    % Stop training if the problem is solved
    if best_fitness >= p.goal_fitness
        disp("Goal Reached - Stopping Training");
        disp("Final number of generations: " + step)
        break;
    end
    
    %% Evaluation
    % Evaluate different NNs until average limit is reached
    for iteration = 1:p.subPop_size * p.num_trials
        %Generate random index of an individual and save it in vector
        chosen_individuals = randi(p.subPop_size, [1, hidden_length]);

        % Form a random NN
        if p.recurrent_nn
            for node = 1:hidden_length      
                weight_matrix(:, p.input_size + node)=...
                   hidden_node(node).individual(chosen_individuals(node)).chromosome;                                
                hidden_node(node).individual(chosen_individuals(node)).participation_count =...
                   hidden_node(node).individual(chosen_individuals(node)).participation_count +1;        
            end
        else
            for node = 1:hidden_length      
                weight_matrix(1:p.input_size, p.input_size + node)=...
                      hidden_node(node).individual(chosen_individuals(node)).chromosome(1:p.input_size);      
                weight_matrix(p.input_size + node,...
                      p.input_size + hidden_length + 1 : end)=...
                      hidden_node(node).individual(chosen_individuals(node)).chromosome(p.input_size + 1:end);
                hidden_node(node).individual(chosen_individuals(node)).participation_count =...
                   hidden_node(node).individual(chosen_individuals(node)).participation_count +1;        
            end
        end

        % Perform the simulation and evaluate the chosen NN
        fitness = esp_twoPoleDemo(p, weight_matrix);
        if fitness > best_fitness
            best_matrix  = weight_matrix;
            best_fitness = fitness;
            best_nodes = hidden_node;
            disp("Best fitness so far: " + best_fitness);
            best_individuals = chosen_individuals;
        end
        
        % Accumulate fitness for each indidual chosen for the current NN
        for node = 1:hidden_length
            hidden_node(node).individual(chosen_individuals(node)).cum_fitness =...
               hidden_node(node).individual(chosen_individuals(node)).cum_fitness + fitness;  
        end
    end
    
    %% Check Stagnation
    if best_fitness <= overall_best_fitness
        static_generations = static_generations + 1;
    else
        overall_best_fitness = best_fitness;
        static_generations   = 0;
    end        
    if static_generations > p.static_limit
        disp("Stagnation reached. Current generation: " + step)
        hidden_node = esp_burst_mutate(best_nodes, best_individuals, p);
        static_generations = 0;
    end
        
    %% Recombination
    for node = 1:hidden_length
        %Find top quartile of population
        score_vector =  zeros(1, p.subPop_size);
        for individual = 1: p.subPop_size
            score_vector(individual) = ...
                hidden_node(node).individual(individual).cum_fitness / ...
                hidden_node(node).individual(individual).participation_count;                
        end
        [sorted_vector, sortend_indices] = sort(score_vector, 'descend');
        top_quartile = floor(quantile(sorted_vector, 0.75));
        
        %Select best individuals from top quartile
        top_individuals = sortend_indices(1:sum(sorted_vector >= top_quartile)); 
        
        %Make all possible combinations of them
        parent_comb = nchoosek(top_individuals, 2);

        %Perfom crossover for all combinations/pairs of best parents
        new_pop = zeros(size(top_individuals, 2) * 2, p.chromo_size);
        pair_count = 0;
        for comb = 1:size(parent_comb, 1)
            parent1 = hidden_node(node).individual(parent_comb(comb, 1)).chromosome;
            parent2 = hidden_node(node).individual(parent_comb(comb, 2)).chromosome;
            index = comb + pair_count;
            new_pop(index:index + 1, :) = esp_crossover(parent1, parent2, p);
            pair_count = pair_count + 1;
        end
        
        %Perfom mutation over newly created individuals
        new_pop = esp_mutation(new_pop, p);
        
        %Replace lowest-ranking half of the subpopulation with newly
        %created individuals. Reset count and fitness for half of subpopulation
        half_point = floor(p.subPop_size/2);
        count = 1;
        for index_1 = p.subPop_size:p.subPop_size - half_point + 1
            hidden_node(node).individual(sortend_indices(index_1)).chromosome = new_pop(count, :);
            hidden_node(node).individual(sortend_indices(index_1)).participation_count = 0;
            hidden_node(node).individual(sortend_indices(index_1)).cum_fitness = 0;
            count = count + 1;
        end 
        
        %Reset count and fitness for second half of subpopulation
        for index_2 = p.subPop_size - half_point : 1
            hidden_node(node).individual(sortend_indices(index_2)).participation_count = 0;
            hidden_node(node).individual(sortend_indices(index_2)).cum_fitness = 0;
        end
    end
end

if final_step == p.num_generations
    disp("Generation limit reached")
    solution_found = false;
end