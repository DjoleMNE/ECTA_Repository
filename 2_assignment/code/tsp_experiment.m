%% Run the algorithm once
clear;
% coordinates = cityData.data(1:10, [3 2])'; % <- switch to plot with north up after imagesc
% plot(coordinates(1,:), coordinates(2,:), 'o');

output = tsp(0.6, 0.1, 1000, true); % Run with hyperparameters

% View Result
% plot([output.fitMax; output.fitMed]','LineWidth', 3);
% 
% legend('Max Fitness','Median Fitness','Location','NorthWest');
% xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
% title('Performance on Task');

%% -- Run experiment multiple times
% As we are not useing parallelism within our algorithm, we can run each
% experiment on a different core to speed things up. This is done by simply
% changing 'for' to 'parfor'. 
clear; 
num_generations = 100;

parfor iExp = 1:10
   output = tsp(0.8, 0.01, num_generations, false);
   fitness(iExp,:) = output.fitMax;
end
standardResult = fitness;

parfor iExp = 1:10
   output = tsp(0.8, 0.1, num_generations, false);
   fitness(iExp,:) = output.fitMax;
end
myResult = fitness;
save('runData.mat','standardResult', 'myResult')

% --- Compute and Plot Results from Raw Data
% * You should always use the median and the 25% / 75% percentiles, 
%   unless you have good reason to think that your data are normally 
%    distributed.
clear; 
load('runData.mat')
gens = 1:length(standardResult);

% Get Significance of comparisons
fit1 = standardResult; fit2 = myResult;
[p, h] = sigPerGen(fit1,fit2);

% Plot results at every generation
figure(2); clf; hold on; C = parula(8); % Create figures and color map

% Plot Significance at every generations
% hS1 = scatter(gens(~h),ones(1,sum(~h)),20,C(1,:),'filled','s');
% hS2 = scatter(gens(h),ones(1,sum(h)),20,C(7,:),'filled','s');

% Plot median and percentiles
[hLine(1), hFill(1)] = percPlot(gens,fit1, C(2,:));
[hLine(3), hFill(2)] = percPlot(gens,fit2, C(5,:));

% Label and make pretty
% hLeg = legend([hFill hS1 hS2],'First param', 'Second param','p > 0.05', 'p < 0.05','Location','SouthEast');
hLeg = legend(hFill,'First param', 'Second param','Location','SouthEast');

axis([0 num_generations min(standardResult) max(standardResult)]); grid on; xlabel('Repetitions'); ylabel('Fitness'); title('Travelling salesman problem'); set(gca,'Fontsize',24);