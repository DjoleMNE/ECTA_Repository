function children  = esp_mutation(input_children, p)
%Mutation - Make random changes in the child population
% - Point mutation:
%Initialize children matrix
children = input_children;

%Iterate over all childrens and their genes
for child = 1:size(input_children, 1)
    
    %Randomly choose genes to mutate
    gene_mutate = rand(1, p.chromo_size);
    
    %Do mutation
    for gene_index = 1:p.chromo_size
        if(gene_mutate(gene_index) < p.mutProb)
            children(child, gene_index) = children(child, gene_index) + trnd(0.3, 1);
%             children(child, :) = swap_genes(children(child, :), gene_index);
        end
    end
end
%------------- END OF CODE --------------