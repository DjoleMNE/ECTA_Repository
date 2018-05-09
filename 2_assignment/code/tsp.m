function output = tsp()
%% randomly init population
items = readtable('cities.csv');

value = items.value;
weight = items.weight;

nGenes = length(value);
maxGen    = 20;           %Max num of Generations
popSize   = 10;           %Number of individuals -> population size
selection_pressure = 2;             
crossProb = 0.8;
mutProb   = 1/nGenes;
elitePerc = 0.1;

%% start evalution
% Data recording
fitMax = nan(1,maxGen);         % Record the maximum fitness
fitMed = nan(1,maxGen);         % Record the median  fitness
best   = nan(nGenes, maxGen); % Record the best individual

%% Generation Loop
for iGen = 1:maxGen    
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        population = randi([1, nGenes], [popSize, nGenes]); % (range, matrix dimensions)
        fitness    = calc_fitness(population, popSize, value);        
    end

    % Data Gathering
    [fitMax(iGen), iBest] = max(fitness); % 1st output is the max value, 2nd the index of that max value
    fitMed(iGen)          = median(fitness);
    best(:,iGen)          = population(iBest,:);
    
    %% Evolutionary Operators
    
    % Selection -- Returns [MX2] indices of parents
    parentIds = my_selection(fitness, popSize, selection_pressure); 
    
    % Crossover -- Returns children of selected parents
    children  = my_crossover(population, parentIds, popSize, nGenes, crossProb);
    
    % Mutation  -- Applies mutation to newly created children
    children  = my_mutation(children, popSize, nGenes, mutProb);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = my_elitism(fitness, popSize, elitePerc);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [population(eliteIds,:); children];
    
    %Remove residual individuals
    population       = newPop(1:popSize,:);  % Keep population size constant
    
    % Evaluate new population
    fitness   = calc_fitness(population, popSize, value);
end

output.fitMax   = fitMax;
output.fitMed   = fitMed;
output.best     = best;