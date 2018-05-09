%% Run the algorithm once
clear;
output = tsp(); % Run with hyperparameters

% View Result
plot([output.fitMax; output.fitMed]','LineWidth',3);

legend('Max Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
title('Performance on Task')