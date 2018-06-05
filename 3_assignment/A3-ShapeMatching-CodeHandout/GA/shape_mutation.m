function children  = shape_mutation(input_children, p)
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
for child = 1:p.popSize
    gene_mutate = rand(1, p.nGenes);
    
    for gene_index = 1:p.nGenes
        if(gene_mutate(gene_index) < p.mutProb)
%             children(child, gene_index) = rand(1) - 0.5;
            children(child, :) = swap_genes(children(child, :), gene_index);
        end
    end
end
%------------- END OF CODE --------------