function output = tsp(plot_single)
%% Initialize population
cityData = importdata('cities.csv');
nCities = 100;
coords = cityData.data(1:nCities, [3 2])'; % <- switch to plot with north up after imagesc %[1:10] row no [3 then 2]
%plot(coords(1,:), coords(2,:), 'o');
%pdist(coords')

%% Algorithm Parameters
popSize = 25;
nGenes  = nCities;
selection_pressure = 2;
elitePerc = 0.1;
mutProb = 1/nGenes;
crossProb = 0.8;
maxGen = 50;
%% Create a single individual
% someInd = [1 4 3 2 5 9 8 7 6 10];
% plot(coords(1,someInd), coords(2,someInd),'-o');
% plotTsp(someInd, coords);

    %% start evalution
% Data recording
fitMax = nan(1,maxGen);         % Record the maximum fitness
fitMed = nan(1,maxGen);         % Record the median  fitness
best   = nan(nCities, maxGen); % Record the best individual
best_distances = nan(maxGen,1);
   %% Evolutionary Operators
for iGen = 1:maxGen    
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        pop = nan([popSize, nGenes]); % (range, matrix dimensions)
        for iPop = 1:popSize
             pop(iPop,:) = randperm(nCities);
        end  
    
    end   
    % Evaluate new population
    fitness   = calc_fitness(pop, popSize, coords,nCities);
    
    % Selection -- Returns [MX2] indices of parents
    selection = my_selection(fitness, popSize, selection_pressure);
    
    % Crossover -- Returns children of selected parents
    children  = my_crossover(pop, selection, popSize, nGenes, crossProb);
    
    % Mutation  -- Applies mutation to newly created children
    children  = my_mutation(children, popSize, nGenes, mutProb);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = my_elitism(fitness, popSize, elitePerc);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [pop(eliteIds,:); children];
    
    %Remove residual individuals
    pop       = newPop(1:popSize,:);  % Keep population size constant
    
    % Evaluate new population
    fitness   = calc_fitness(pop, popSize, coords,nCities);
    result = fitness(:,1);
    normalized_fitness = result/sum(result);
end

[fitMax(iGen), iBest] = max(normalized_fitness); % 1st output is the max value, 2nd the index of that max value
fitMed(iGen)          = median(normalized_fitness);
best(:,iGen)          = pop(iBest,:);
best_distances(iGen)  = fitness(iBest,2);


output.fitMax   = fitMax;
output.fitMed   = fitMed;
output.best     = best;
output.best_distances = best_distances;


%% Plotting
if plot_single
    subplot(1,2,1);
        plotTsp(output.best(:,end)', coords);
        title('Best individual')
    subplot(1,2,2);
        plot(1:1:maxGen, output.best_distances);
        title('Learning curve')
end