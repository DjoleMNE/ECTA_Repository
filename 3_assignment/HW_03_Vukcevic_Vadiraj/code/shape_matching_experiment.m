%% Run the algorithm once
clc; clear all;
tic
n_param = shape_matching_ga();
p = shape_matching_ga(n_param);
output = shape_matching_ga(n_param, p);
disp("Foil calculated")
toc

%% Plotting fitness
figure(2); clf; hold on;
plot([output.fitMax; output.fitMed]','LineWidth',3);
legend('Min Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Mean square error'); set(gca,'FontSize',16);
title('Performance of Shape formation')

%% Calculating the best individual
[lowest, ilowest] = min(output.fitMax);
smallest = output.best(:,ilowest)';

%% Plotting the best individual
%plotfoil(smallest', n_param)
