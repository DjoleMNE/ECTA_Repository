
%% Run the algorithm once
clear;
output = tsp(true); % Run with hyperparameters

%% -- Run experiment multiple times
% As we are not useing parallelism within our algorithm, we can run each
% experiment on a different core to speed things up. This is done by simply
% changing 'for' to 'parfor'. 
clear;
parfor iExp = 1:20
   output = tsp(false);
   fitness(iExp,:) = output.fitMax;
end
standardResult = fitness;

parfor iExp = 1:20
   output = tsp();
   fitness(iExp,:) = output.fitMax;
end
myResult = fitness;
save('runData.mat','standardResult', 'myResult')

clear; 
load('runData.mat')
gens = 1:length(standardResult);

% Get Significance of comparisons
fit1 = standardResult; fit2 = myResult;
[p,h] = sigPerGen(fit1,fit2);

% Plot results at every generation
figure(2); clf; hold on; C = parula(8); % Create figures and color map

% Plot Significance at every generations
hS1 = scatter(gens(~h),ones(1,sum(~h))*19,20,C(1,:),'filled','s');
hS2 = scatter(gens(h),ones(1,sum(h))*19,20,C(7,:),'filled','s');

% Plot median and percentiles
[hLine(1), hFill(1)] = percPlot(gens,fit1 ,C(2,:));
[hLine(3), hFill(2)] = percPlot(gens,fit2,C(5,:));

% Label and make pretty
hLeg = legend([hFill hS1 hS2],'Baseline', 'No Mutation','p > 0.05', 'p < 0.05','Location','SouthEast');
axis([0 200 0 19]); grid on; xlabel('Generations'); ylabel('Fitness'); title('Fitness on Hamlet Quote'); set(gca,'Fontsize',24);


% View Result
plot([output.fitMax; output.fitMed]','LineWidth',3);

legend('Max Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
title('Performance on Task')