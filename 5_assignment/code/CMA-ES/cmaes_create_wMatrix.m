function weight_matrix = cmaes_create_wMatrix(chromosome, p)
weight_matrix = zeros(p.net_size);

for node = 1:p.num_hidden
    node_connection = chromosome(((node - 1) * p.num_open) + 1: node * p.num_open);
    
    weight_matrix(1:p.input_size, p.input_size + node) = node_connection(1:p.input_size);  
   
    weight_matrix(p.input_size + node, p.input_size + p.num_hidden + 1 : end) =...
            node_connection(p.input_size + 1:end);
end