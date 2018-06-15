function children  = shape_matching_mutation(input_children, p)

% children = input_children;
% 
% %Iterate over all childrens and their genes
% for child = 1:p.popSize
%     gene_mutate = rand(1, p.nGenes);
%     for gene_index = 1:p.nGenes
%         if(gene_mutate(gene_index) < p.mutProb)
% %             swap_index = randi(p.nGenes);
% %             while(swap_index == gene_index)
% %                 swap_index = randi(p.nGenes);
% %             end
%             children(child, :) = swap_genes(children(child, :), gene_index);
%         end
%     end
% end


children = input_children; 

%% POINT MUTATION SOLUTION
% for child = 1:p.popSize
%    gene_mutate = rand(1,p.nGenes);
%    for gene = 1:p.nGenes
%        if(gene_mutate(gene) < p.mutProb)
%            children(child,gene) = rand - 0.5;
%        end
%    end
% end

%% Swap mutation
for child = 1: p.popSize
    gene_mutate = rand(1,p.nGenes);
    for gene = 1:p.nGenes
        if(gene_mutate(gene) < p.mutProb)
            children(child, :) = swap_genes(children(child,:), gene);
        end
    end
end
            
        
%------------- END OF CODE --------------