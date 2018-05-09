function children  = my_mutation(input_children, popSize, nGenes, mutProb)
%Mutation - Make random changes in the child population
% - Point mutation:
% Syntax:  children  = my_mutation(children, p);
%
% Inputs:
%    children   - [M X N] - Population of M individuals
%    mutProb              - Chance per gene of performing mutation
%
% Outputs:
%    children   - [M X N] - New population of M individuals
%

%------------- BEGIN CODE --------------
%Initialize children matrix and seed of random generator
children = input_children;

%Iterate over all childrens and their genes
for child = 1:popSize
    gene_mutate = rand(1, nGenes);
    for gene = 1:nGenes
        if(gene_mutate(gene) < mutProb)
            children(child, gene) = ~children(child, gene);
        end
    end
end
%------------- END OF CODE --------------