function children  = my_crossover(pop, parentIds, p)
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

children = pop( parentIds(:,1) ,:);

% rand(range, size of vector/matrix)
doXover = (rand(1,p.popSize) < p.crossProb);            % Crossover or not?

% randi([range], size of vector/matrix)
%pose of gene can be from 1 to 17
crossPt = randi([1 p.nGenes-1],1,p.popSize) .* doXover; % Get Crossover Pts

for iChild = 1:p.popSize
   partA = 1:crossPt(iChild);
   partB = 1+crossPt(iChild) : size(pop,2); %size(pop,2) = 18
   
   %concatenate partA indices/genes of individual with partB indices/genes...both from pop
   children(iChild,:) = ...
       [pop(parentIds(iChild,1), partA), pop(parentIds(iChild,2), partB)];
end
%------------- END OF CODE -------------