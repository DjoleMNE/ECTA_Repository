function children  = my_mutation(input_children, p)
%Mutation - Make random changes in the child population
% - Point mutation:
%   1) Determine which genes will be mutated -- all have an equal chance
%   2) Change every gene chosen for mutation to another random value
%
% Syntax:  children  = my_mutation(children, p);
%
% Inputs:
%    children   - [M X N] - Population of M individuals
%    p          - _struct - Hyperparameter struct
%     .mutProb              - Chance per gene of performing mutation
%
% Outputs:
%    children   - [M X N] - New population of M individuals
%
% See also: selection, crossover, elitism, monkeyGa

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------
children = input_children;
rng;

%Choose randomly which genes need to be mutated
doMut = (randn(p.popSize,p.nGenes) < p.mutProb);     % Mutate genes or not?

%Generate new random values for genes that are chosen for mutation
children(doMut) = randi([0 27], [1 sum(doMut(:))]); % Change to random values
%------------- END OF CODE --------------