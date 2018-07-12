function children = esp_mutation(input_children, p)
%Mutation - Make random changes in the child population
% - Point mutation:
%Initialize children matrix
children = input_children;

%Iterate over all childrens and their genes
for child = 1:size(input_children, 1)    
    %Randomly choose gene to mutate
    if(rand(1) < p.mutProb)
        children(child, randi(p.chromo_size, 1)) = cauchyrnd();
    end
end
%------------- END OF CODE --------------