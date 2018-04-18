%% Run the algorithm once
clear;
p = monkeyGa('hamletQuote');  % Set hyperparameters
output = monkeyGa('hamletQuote',p); % Run with hyperparameters

% View Result
gene2text(output.best(:,end)')
plot([output.fitMax; output.fitMed]','LineWidth',3);
legend('Max Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
title('Performance on Hamlet Task')

%% -- Run experiment multiple times
% As we are not useing parallelism within our algorithm, we can run each
% experiment on a different core to speed things up. This is done by simply
% changing 'for' to 'parfor'. 
clear; p = monkeyGa('hamletQuote');
parfor iExp = 1:20
   output = adamGa('hamletQuote',p);
   gene2text(output.best(:,end)')
   fitness(iExp,:) = output.fitMax;
end
standardResult = fitness;

parfor iExp = 1:20
   output = monkeyGa('hamletQuote',p);
   gene2text(output.best(:,end)')
   fitness(iExp,:) = output.fitMax;
end
myResult = fitness;
save('runData.mat','standardResult', 'myResult')

% --- Compute and Plot Results from Raw Data
% Using the mean + standard deviation assumes that your data are normally
% distributed. This assumption is usually wrong in evolutionary computation
% (and in experimental computer science). For instance, your algorithm may
% fail 30% of the time (fitness = 0) and succeed 70% of the time (fitness =
% 1): you have two peaks and the distribution is not Gaussian at all. In
% addition, the standard deviation assumes that the distribution is
% symmetric, which is clearly not the case when there is a maximum that
% cannot be exceeded.

% *** You should always use the median and the 25% / 75% percentiles, 
%     unless you have good reason to think that your data are normally 
%     distributed.
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

%% The whole monologue
clear; p = monkeyGa('hamletSoliloquy');
p.maxGen  = 10000;              % Increase the number of generations
tic;                            % Start the timer
output = monkeyGa('hamletSoliloquy',p);
gene2text(output.best(:,end)')  % Show the found text
percentCorrect = (output.fitMax(end)/1446);
timeToComplete = toc;           % End the timer
disp([num2str(100*percentCorrect) '% correct in ' (timeToComplete) ' seconds'])

%% Timing a single evaluation
aWholeBunchOfTimes = 100000;
test = randi([0 27], [aWholeBunchOfTimes, p.nGenes]);
tic; hamletSoliloquy(test); tEnd = toc;
oneEval = tEnd/aWholeBunchOfTimes;

%% Timing a single evaluation
aWholeBunchOfTimes = 100000;
test = randi([0 27], [aWholeBunchOfTimes, p.nGenes]);
tic; hamletSoliloquy(test); tEnd = toc;
oneEval = tEnd/aWholeBunchOfTimes;
disp(['One evaluation in ' num2str(oneEval) ' seconds'])




