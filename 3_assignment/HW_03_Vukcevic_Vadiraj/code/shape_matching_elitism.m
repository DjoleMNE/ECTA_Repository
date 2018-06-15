function eliteIds = shape_matching_elitism(fitness, p)
%Elitism - Get indices of individual(s) to continue unchanged into next pop
% - Standard Elitism:
%   1) Find 1 best performing individual
%   * Optional: In very large populations select a top percentage
%
% Syntax:  eliteId   = my_elitism(fitness, p)
%
% Inputs:
%    fitness    - [M X 1] - Fitness of every individual in the population
%    elitePercent         - Percentage of pop to take as elites (min 1)
%
% Outputs:
%    eliteIds   - [nElites X 1] - Indices of each elite

%------------- BEGIN CODE --------------
elite_individuals = p.popSize * p.elitePerc;

[~,sorted_ids]= sort(fitness,'ascend');  

eliteIds = sorted_ids(1:ceil(elite_individuals));              
%------------- END OF CODE --------------