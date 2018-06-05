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
output = shape_ES(rand(1) + 0.05, nacafoil, numEvalPts); % Run with hyperparameters
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

% View Result in numbers
% figure(2); clf; hold on; % Create figures and color map
% grid on;
% plot([output.fitMax; output.fitMed]','LineWidth',1);
% display(output.fitMax(end));
% legend('Max Fitness','Median Fitness','Location','SouthEast');
% xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
% title('Fitness')

%% Run experiment multiple times
% clear; 
% num_generations = 1000;
% 
% parfor iExp = 1:30
%    output = tsp(0.99, 0.01, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_1 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.99, 0.1, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_2 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.99, 0.99, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_3 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.99, 0.5, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_4 = fitness;
% 
% gens = 1:length(result_1);
% 
% median_fitness = NaN(4, num_generations);
% median_fitness(1, :) = median(result_1);
% median_fitness(2, :) = median(result_2);
% median_fitness(3, :) = median(result_3);
% median_fitness(4, :) = median(result_4);  
% 
% % Plot results at every generation
% figure(2); clf; hold on; % Create figures and color map
% 
% plot(gens, median_fitness(1, :),... 
%             gens, median_fitness(2, :),... 
%             gens, median_fitness(3, :),... 
%             gens, median_fitness(4, :));
%         
% lgd_1 = legend('Rate 1', 'Rate 2', 'Rate 3', 'Rate 4');
% title(lgd_1,'Mutation rates')
% 
% grid on; xlabel('Generations'); ylabel('Distances'); title('Travelling salesman problem - Mutation test'); set(gca,'Fontsize',24);
% 
% 
% %% Crossover test -> Run experiment multiple times
% clear; 
% num_generations = 1000;
% 
% parfor iExp = 1:30
%    output = tsp(0.01, 0.01, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_1 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.1, 0.01, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_2 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.99, 0.01, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_3 = fitness;
% 
% parfor iExp = 1:30
%    output = tsp(0.5, 0.01, num_generations, false);
%    fitness(iExp,:) = output.best_distances;
% end
% result_4 = fitness;
% 
% gens = 1:length(result_1);
% 
% median_fitness = NaN(4, num_generations);
% median_fitness(1, :) = median(result_1);
% median_fitness(2, :) = median(result_2);
% median_fitness(3, :) = median(result_3);
% median_fitness(4, :) = median(result_4);  
% 
% % Plot results at every generation
% figure(3); clf; hold on; % Create figures and color map
% 
% plot(gens, median_fitness(1, :),... 
%             gens, median_fitness(2, :),... 
%             gens, median_fitness(3, :),... 
%             gens, median_fitness(4, :));
% 
% lgd_2 = legend('Rate 1', 'Rate 2', 'Rate 3', 'Rate 4');
% title(lgd_2,'Crossover rates')
% 
% grid on; xlabel('Generations'); ylabel('Distances'); title('Travelling salesman problem - Crossover test'); set(gca,'Fontsize',24);