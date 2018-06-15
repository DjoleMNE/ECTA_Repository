function output = shape_matching_ga(wing_type,task,n_param,p)
%% randomly init population
if nargin< 2
    n_param.numEvalPts = 256;                           % Num evaluation points
            
        switch wing_type
            case 1
                n_param.nacaNum = [0,0,1,2];
%                 
            case 2
                n_param.nacaNum = [5,5,2,2];
%                
            case 3
                n_param.nacaNum = [9,7,3,5];
%                 
            otherwise
               n_param.nacaNum = [0,0,1,2];
%                 
        end
    n_param.nacaNum = [0,0,1,2];                        % NACA Parameters
    n_param.nacafoil= create_naca(n_param.nacaNum,n_param.numEvalPts);  % Create foil
    output = n_param;
    return
elseif nargin< 4
    % p.individual = rand(32,1)-0.5;
    p.task = task;
    p.nGenes    = 32;
    p.maxGen    = 1000;           %Max num of Generations
    p.popSize   = 100;           %Number of individuals -> population size
    p.selection_pressure = 2;
    p.crossProb = 0.9;
    p.mutProb   = 0.7
    p.elitePerc = 0.1;
    output = p;
    return
end
%% start evalution
% Data recording
fitMax           = nan(1, p.maxGen);         % Record the maximum fitness
fitMed           = nan(1, p.maxGen);         % Record the median  fitness
best             = nan(p.nGenes, p.maxGen); % Record the best individual

%% Generation Loop
for iGen = 1:p.maxGen
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        %Population matrix
        population = NaN(p.popSize, p.nGenes); % (range, matrix dimensions)
        
        % Create a population
 %       for iPop = 1:p.popSize
            %Getting the foils of each individual
            population = rand(p.popSize,p.nGenes)-0.5;
           % 
%
        
        fitness  = calculate_fitness(n_param,population,p);
        %fitness = result(:, 1);
        %normalized_fitness = fitness/sum(fitness);
    end
    
    % Data Gathering
    [fitMax(iGen), iBest] = min(fitness); % 1st output is the max value, 2nd the index of that max value
    fitMed(iGen)          = median(fitness);
    best(:,iGen)          = population(iBest,:);
    
    
    %% Evolutionary Operators
    %Plotting
    plotfoil(best(:,iGen), n_param)
    % Selection -- Returns [MX2] indices of parents
    parentIds = shape_matching_selection(fitness, p);
    
    % Crossover -- Returns children of selected parents
    children  = shape_matching_crossover(population, parentIds, p);
    
    % Mutation  -- Applies mutation to newly created children
    children  = shape_matching_mutation(children, p);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = shape_matching_elitism(fitness, p);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [population(eliteIds,:); children];
    
    %Remove residual individuals
    population       = newPop(1:p.popSize,:);  % Keep population size constant
    % Evaluate new population
    for iPop = 1:p.popSize
        [n_param.foil{iPop}, ~] = pts2ind(population(iPop,:)', n_param.numEvalPts);
    end
    
    
    fitness    = calculate_fitness(n_param,population,p);
    %   fitness = result(:,1);
    %   normalized_fitness = fitness/sum(fitness);
end

%% Setting outputs
output.fitMax        = fitMax;
output.fitMed        = fitMed;
output.best          = best;
end