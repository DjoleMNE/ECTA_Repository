function output = tsp(crossProb, mutProb, num_generations, plot_single)
cityData = importdata('cities.csv');
%% randomly init population
p.nCities = 100;
coordinates  = cityData.data(1:p.nCities, [3 2])';

p.nGenes = p.nCities;
p.maxGen    = num_generations;           %Max num of Generations
p.popSize   = 200;           %Number of individuals -> population size
p.selection_pressure = 2;             
p.crossProb = crossProb;
p.mutProb   = mutProb;
p.elitePerc = 0.1;

%% start evalution
% Data recording
fitMax           = nan(1, p.maxGen);         % Record the maximum fitness
fitMed           = nan(1, p.maxGen);         % Record the median  fitness
best             = nan(p.nGenes, p.maxGen); % Record the best individual
best_distances   = nan(p.maxGen, 1); % Record the best distances

%% Generation Loop
for iGen = 1:p.maxGen    
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        %Initialize Population matrix
        population = NaN(p.popSize, p.nGenes); % (range, matrix dimensions)
        
        % Create a population
        for iPop = 1:p.popSize
            population(iPop,:) = randperm(p.nGenes);
        end
        
        result    = calc_fitness(population, coordinates, p);  
        fitness = result(:, 1);
        normalized_fitness = fitness/sum(fitness);
    end

    % Data Gathering
    [fitMax(iGen), iBest] = max(normalized_fitness); % 1st output is the max value, 2nd the index of that max value
    fitMed(iGen)          = median(normalized_fitness);
    best(:,iGen)          = population(iBest,:);
    best_distances(iGen)  = result(iBest, 2);
    
    %% Evolutionary Operators
    % Selection -- Returns [MX2] indices of parents
    parentIds = tsp_selection(normalized_fitness, p); 
    
    % Crossover -- Returns children of selected parents
    children  = tsp_crossover(population, parentIds, p);
    
    % Mutation  -- Applies mutation to newly created children
    children  = tsp_mutation(children, p);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = tsp_elitism(normalized_fitness, p);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [population(eliteIds,:); children];
    
    %Remove residual individuals
    population       = newPop(1:p.popSize,:);  % Keep population size constant
    
    % Evaluate new population
    result    = calc_fitness(population, coordinates, p);  
    fitness = result(:,1);
    normalized_fitness = fitness/sum(fitness);
end

%% Setting outputs
output.fitMax        = fitMax;
output.fitMed        = fitMed;
output.best          = best;
output.best_distances = best_distances;


%% Plotting
if plot_single
    subplot(1,2,1);
        plotTsp(output.best(:,end)', coordinates);
        title('Best individual')
    subplot(1,2,2);
        plot(1:1:p.maxGen, output.best_distances);
        title('Learning curve')
end
