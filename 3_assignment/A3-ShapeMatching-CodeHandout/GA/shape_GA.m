function output = shape_GA(crossProb, mutProb, num_generations, nacafoil, numEvalPts)

%% randomly init population
p.nGenes = 32;
p.maxGen    = num_generations;           %Max num of Generations
p.popSize   = 100;           %Number of individuals -> population size
p.selection_pressure = 2;             
p.crossProb = crossProb;
p.mutProb   = mutProb;
% p.mutProb   = 1/p.nGenes;
p.elitePerc = 0.1;

%% start evalution
% Data recording
fitMax           = nan(1, p.maxGen);         % Record the maximum fitness
fitMed           = nan(1, p.maxGen);         % Record the median  fitness
best             = nan(p.nGenes, p.maxGen); % Record the best individual
best_foils       = nan(2, numEvalPts, p.maxGen);

%% Generation Loop
for iGen = 1:p.maxGen    
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        %Initialize Population matrix
        population = rand(p.popSize, p.nGenes) - 0.5; % (range, matrix dimensions)
        
        % Create a population
%         for iPop = 1:p.popSize
%             population(iPop,:) = randperm(p.nGenes);
%         end
        
        [fitness, foils] = shape_calc_fitness(population, nacafoil, numEvalPts, p);      
        normalized_fitness = fitness/sum(fitness);
    end

    % Data Gathering
    [fitMax(iGen), iBest] = max(fitness); % 1st output is the max value, 2nd the index of that max value
    fitMed(iGen)          = median(fitness);
    best(:,iGen)          = population(iBest,:);
    best_foils(:, :, iGen) = foils(:, :, iBest);
    
    % Visualize shape in run time
%     foil = foils(:, :, iBest);
%     figure(1);
%     plot(nacafoil(1,:),nacafoil(2,:), 'LineWidth', 3);
%     hold on;
%     plot(foil(1,:),foil(2,:), 'r', 'LineWidth', 3);
%     axis equal;
%     axis([0 1 -0.7 0.7]);
%     legend('NACA 0012 target', 'Approximated Shape');
%     ax = gca;
%     ax.FontSize = 24;
%     drawnow;
%     hold off;
    
    %% Evolutionary Operators
    % Selection -- Returns [MX2] indices of parents
    parentIds = shape_selection(normalized_fitness, p); 
    
    % Crossover -- Returns children of selected parents
    children  = shape_crossover(population, parentIds, p);
    
    % Mutation  -- Applies mutation to newly created children
    children  = shape_mutation(children, p);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = shape_elitism(normalized_fitness, p);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [population(eliteIds,:); children];
    
    %Remove residual individuals
    population       = newPop(1:p.popSize,:);  % Keep population size constant
    
    % Evaluate new population
    [fitness, foils] = shape_calc_fitness(population, nacafoil, numEvalPts, p);      
    normalized_fitness = fitness/sum(fitness);
end

%% Setting outputs
output.fitMax        = fitMax;
output.fitMed        = fitMed;
output.best          = best;
output.best_foils    = best_foils;
