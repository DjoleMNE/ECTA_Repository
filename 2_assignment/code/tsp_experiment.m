%% Run the algorithm once
clear;
output = tsp(0.99, 0.01, 1000, true); % Run with hyperparameters

%% Mutation test -> Run experiment multiple times
clear; 
num_generations = 500;

parfor iExp = 1:30
   output = tsp(0.8, 0.01, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_1 = fitness;

parfor iExp = 1:30
   output = tsp(0.8, 0.1, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_2 = fitness;

parfor iExp = 1:30
   output = tsp(0.8, 0.99, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_3 = fitness;

parfor iExp = 1:30
   output = tsp(0.8, 0.5, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_4 = fitness;

gens = 1:length(result_1);

median_fitness = NaN(4, num_generations);
median_fitness(1, :) = median(result_1);
median_fitness(2, :) = median(result_2);
median_fitness(3, :) = median(result_3);
median_fitness(4, :) = median(result_4);  

% Plot results at every generation
figure(2); clf; hold on; % Create figures and color map

plot(gens, median_fitness(1, :),... 
            gens, median_fitness(2, :),... 
            gens, median_fitness(3, :),... 
            gens, median_fitness(4, :));
        
lgd_1 = legend('Rate 1', 'Rate 2', 'Rate 3', 'Rate 4');
title(lgd_1,'Mutation rates')

grid on; xlabel('Generations'); ylabel('Distances'); title('Travelling salesman problem - Mutation test'); set(gca,'Fontsize',24);


%% Crossover test -> Run experiment multiple times
clear; 
num_generations = 500;

parfor iExp = 1:30
   output = tsp(0.01, 0.1, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_1 = fitness;

parfor iExp = 1:30
   output = tsp(0.1, 0.1, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_2 = fitness;

parfor iExp = 1:30
   output = tsp(0.99, 0.1, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_3 = fitness;

parfor iExp = 1:30
   output = tsp(0.5, 0.1, num_generations, false);
   fitness(iExp,:) = output.best_distances;
end
result_4 = fitness;

gens = 1:length(result_1);

median_fitness = NaN(4, num_generations);
median_fitness(1, :) = median(result_1);
median_fitness(2, :) = median(result_2);
median_fitness(3, :) = median(result_3);
median_fitness(4, :) = median(result_4);  

% Plot results at every generation
figure(3); clf; hold on; % Create figures and color map

plot(gens, median_fitness(1, :),... 
            gens, median_fitness(2, :),... 
            gens, median_fitness(3, :),... 
            gens, median_fitness(4, :));

lgd_2 = legend('Rate 1', 'Rate 2', 'Rate 3', 'Rate 4');
title(lgd_2,'Crossover rates')

grid on; xlabel('Generations'); ylabel('Distances'); title('Travelling salesman problem - Crossover test'); set(gca,'Fontsize',24);