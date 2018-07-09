function mutated_nodes = esp_burst_mutate(all_nodes, best_individuals, p)
%Initialize new nodes with old ones
mutated_nodes = all_nodes;

%Add noise to each gene in each individual
for node = 1:p.num_hidden
    for index = 1:p.subPop_size
        noise = cauchyrnd(0.0, 1.0, [1, p.chromo_size]);
        mutated_nodes(node).individual(index).chromosome = ...
                all_nodes(node).individual(best_individuals(node)).chromosome...
                + noise;
    end
end