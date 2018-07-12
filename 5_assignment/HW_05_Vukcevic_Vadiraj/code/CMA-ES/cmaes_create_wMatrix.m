function weight_matrix = cmaes_create_wMatrix(chromosome, p)
weight_matrix = zeros(p.net_size);

if p.recurrent_nn
    hidden_length = p.num_hidden + p.output_size;
else
    hidden_length = p.num_hidden;
end

if ~p.recurrent_nn
    % Write weights for FF NN
    for node = 1:hidden_length
        node_connection = chromosome(((node - 1) * p.num_open) + 1: node * p.num_open);
        weight_matrix(1:p.input_size, p.input_size + node) = node_connection(1:p.input_size); 
        weight_matrix(p.input_size + node, p.input_size + p.num_hidden + 1 : end) =...
                node_connection(p.input_size + 1:end);
    end
else
    % Write weights for R NN
    for node = 1:hidden_length      
        weight_matrix(:, p.input_size + node) = ...
            chromosome(((node - 1) * p.net_size) + 1: node * p.net_size);        
    end
end