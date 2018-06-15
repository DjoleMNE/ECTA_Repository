%% GA Real value - Single run
clc; clear all;
tic
wing_type = 1;
n_param = shape_matching_ga(wing_type);
p = shape_matching_ga(wing_type,'meansquaremulti', n_param);
output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
disp("Foil calculated")
toc
%% Plotting fitness
plot([output.fitMax; output.fitMed]','LineWidth',3);
legend('Min Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
title('Performance of GeneticAlgorithm')

%% Calculating the best individual
[lowest, ilowest] = min(output.fitMax);
smallest = output.best(:,ilowest)';

%% Plotting the best individual
plotfoil(smallest', n_param)

%NOTE: Pending finding the right parameters to improve performance. 

%% Evaluating over 20 runs the GAs
clc; clear all;
wing_type = 1;
tic;
fitness = [];
%Real value
parfor iExp = 1:20
    n_param = shape_matching_ga(wing_type);
    p = shape_matching_ga(wing_type,'meansquaremulti', n_param);
    output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
%    fitness(iExp,:) = output.fitMax;
    fitness(iExp,:) = output.fitMed;
   % [lowest, ilowest] = min(output.fitMax);
%    best = output.best(:,ilowest)';
%    best_ind{iExp} = {best, lowest};
end

toc;
GAmedianFitness = fitness;
disp('GA done')
save(['GA_median_Fitness'],'GAmedianFitness')
load('GA_median_Fitness.mat')
%Extracting the values from the best_ind cells
% for i=1:20
%     penalize(i) = best_ind{i}{2};
% end
% 
% %Getting the best individual
% [~, iVal] = min(penalizations);
% smallest_Real = best_ind{iVal}{1};
% GA_Real_value_Fitness = mean(fitness);
% 
% tic;



%n_param = shape_matching_ga(wing_type);
% myMedian = mean(fit_median);
plot([GA_Real_Fitness]','LineWidth',3);
legend('Real Fitness Mean','Location','NorthEast');
xlabel('Generations'); ylabel('Fitness Values'); set(gca,'FontSize',16,'YScale','log');
title('Representation of real values')

