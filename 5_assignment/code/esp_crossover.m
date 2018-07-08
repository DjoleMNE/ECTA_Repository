function children = esp_crossover(parent_1, parent_2, p)
%Crossover - Creates child solutions by combining genes of parents
% - Single Point Crossover:

%Initialize children matrix
children = zeros(2, p.chromo_size);

% randi([range], size of vector/matrix)
cross_point = randi(p.chromo_size - 1);
first_part = parent_1(1, 1 : cross_point);
second_part = parent_2(1, (cross_point + 1) : end);

%concatenate partA indices/genes with partB indices/genes
children(1, :) = [first_part second_part];
children(2, :) = [second_part first_part];
%------------- END OF CODE -------------