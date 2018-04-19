function children = my_crossover(pop, parentIds, p)
%Crossover - Creates child solutions by combining genes of parents
% - Single Point Crossover:
%   1) For each set of parents:
%   2) Determine whether or not to perform crossover (p.crossProb)
%   3) If not, take first parent as child
%   4) If yes, choose random point along genome and:
%   5) Create child from genes behind point from parent A and in front of
%   that point from parent B
%
% Syntax:  children  = crossover(pop, parentIds, p)
%
% Inputs:
%    pop        - [M X N] - Population of M individuals
%    parentIds  - [M X 2] - Parent pair indices
%    p          - _struct - Hyperparameter struct
%     .crossProb            - Chance of performing crossover
%
% Outputs:
%    children   - [M X N] - New population of M individuals
%
% See also: selection, mutation, elitism, monkeyGa

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------
%Initialize children matrix by assigning only first individual of all pairs
children = pop(parentIds(:,1) ,:);
for child=1:p.popSize
    %Should crossover be perform or  not
    % rand(size of vector/matrix)
    crossover_decision = rand(1) < p.crossProb;
    
    if crossover_decision
       %position of a gene can be from 1 to 17
       % randi([range], size of vector/matrix)
       cross_point = randi(p.nGenes-1);
       first_part = pop(parentIds(child,2),1:cross_point);
       second_part = pop(parentIds(child,1),(cross_point+1):p.nGenes);
       %concatenate partA indices/genes with partB indices/genes from pop
       children(child,:) = [first_part second_part];
    end
end
%------------- END OF CODE -------------