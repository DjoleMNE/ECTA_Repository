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
%Initialize children matrix and seed of random generator
children = input_children; rng;
%Iterate over all childrens and their genes
for child = 1:p.popSize
    gene_mutate = rand(1,p.nGenes);
    for gene = 1:p.nGenes
        if(gene_mutate(gene) < p.mutProb)
            children(child,gene) = randi([0 27],1);
        end
    end
end
%------------- END OF CODE --------------