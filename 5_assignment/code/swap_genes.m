function individual = swap_genes(child, index_1)
individual = child;
temp_gene = individual(index_1);
if (index_1 ~= length(individual))
    individual(index_1) = individual(index_1+1);
    individual(index_1+1) = temp_gene;
else 
    individual(index_1) = individual(index_1-1);
    individual(index_1 - 1) = temp_gene;
end
