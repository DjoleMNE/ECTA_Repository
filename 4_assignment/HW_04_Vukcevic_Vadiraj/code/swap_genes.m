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

% fliped_child = flip(child);
% if(index_1 == 1 && index_2 == length(child))
%     individual = fliped_child;
% end
% 
% 
% elseif(index_1 == 1)
%    individual = [fliped_child(index_1:index_2) child(index_2 + 1:end)]; 
% end
% 
% individual = [child(1:index_1-1)...
%               fliped_child(index_1:index_2)...
%               child(index_2 + 1:end)];