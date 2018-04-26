function output = monkeyGa(task, p)
%hamletGa - Main Genetic Algorithm script for Hamlet and Infinite Monkeys
% Run this function with your own code filled in to complete the
% assignment, feel free to add anything you want, but for analysis be sure
% to output the same fitness info.
%
% Syntax:  output = monkeyGa(task, p)
%
% Inputs:
%    task   - _string  - name of fitness function
%    p      - _struct  - hyperparameters of run
%
% Outputs:
%   output  - _struct  - result of run
%   .fitMax - [1 X N]  - Best fitness in each generation
%   .fitMed - [1 X N]  - Median fitness in each generation
%   .best   - [M X N]  - Genes of best individual in each generation
%
% Example: 
%     %% The quote
%     p = monkeyGa('hamletQuote');
%     output = monkeyGa('hamletQuote',p);
%     gene2text(output.best(:,end)')
% 
%     %% The whole monologue
%     p = monkeyGa('hamletSoliloquy');
%     p.maxGen  = 10000;
%     output = monkeyGa('hamletSoliloquy',p);
%     gene2text(output.best(:,end)')
%
% Other m-files required: selection, crossover, mutation, elitism,
% hamletQuote, hamletSoliloquy
%
% See also: selection, crossover, mutation, elitism

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------- Default Hyperparameters -------
if nargin<2     % > When called with only the task name, this function 
                %   only outputs the default hyperparameters. The function
                %   runs when it is given both a task and a hyperparameter
                %   set
    p.task      = task;          % > The task here is a string, which is 
                                 %   the function name.
    p.nGenes    = feval(p.task); % > feval evaluates a function. we have 
                                 %   programmed our fitness functions to 
                                 %   return the number of genes when no
                                 %   input arguments are given to make it
                                 %   easier to switch between tasks.
    p.maxGen    = 200;
    p.popSize   = 100;
    p.sp        = 3;
    p.crossProb = 0.8;
    p.mutProb   = 1/p.nGenes;
    p.elitePerc = 0.01;
    output      = p;             % Output default hyperparameters
    return
end
%------------- BEGIN CODE --------------
p.task      = task;
p.nGenes    = feval(p.task);

% Data recording
% - You will use this data to visualize your current run and compare across
% multiple runs. Though it is not required, we initialize the matrices
% which will hold the run data.
fitMax = nan(1,p.maxGen);         % Record the maximum fitness
fitMed = nan(1,p.maxGen);         % Record the median  fitness
best   = nan(p.nGenes, p.maxGen); % Record the best individual

%% Generation Loop
for iGen = 1:p.maxGen    
    %% Initialize population
    % - Initialize a population of random individuals and evaluate them.
    if iGen == 1
        pop         = randi([0 27], [p.popSize, p.nGenes]); % (range, matrix dimensions)
        fitness     = feval(p.task, pop);        
    end

    % Data Gathering
    [fitMax(iGen), iBest] = max(fitness); % 1st output is the max value, 2nd the index of that max value
    fitMed(iGen)          = median(fitness);
    best(:,iGen)          = pop(iBest,:);
    
    %% Evolutionary Operators
    
    % Selection -- Returns [MX2] indices of parents
    parentIds = adam_selection(fitness, p); % Returns indices of parents
    
    % Crossover -- Returns children of selected parents
    children  = adam_crossover(pop, parentIds, p);
    
    % Mutation  -- Applies mutation to newly created children
    children  = adam_mutation(children, p);
    
    % Elitism   -- Select best individual(s) to continue unchanged
    eliteIds  = adam_elitism(fitness, p);
    
    % Create new population -- Combine new children and elite(s)
    newPop    = [pop(eliteIds,:); children];
    pop       = newPop(1:p.popSize,:);  % Keep population size constant
    
    % Evaluate new population
    fitness   = feval(p.task, pop);
    
    %% Plot Population Progress
    % Comment this out or create a variable to toggle its execution when
    % running batch experiments.
%     if ~mod(iGen,100)
%         plot([fitMax; fitMed]');
%         legend('Max Fitness','Median Fitness','Location','NorthWest');
%         drawnow;
%     end
end

output.fitMax   = fitMax;
output.fitMed   = fitMed;
output.best     = best;
%------------- END OF CODE --------------