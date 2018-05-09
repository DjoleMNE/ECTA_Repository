function children = my_crossover(pop, parentIds, popSize, nGenes, crossProb)
%Crossover - Creates child solutions by combining genes of parents
% - Single Point Crossover:
% Syntax:  children  = crossover(pop, parentIds, p)
%
% Inputs:
%    pop        - [M X N] - Population of M individuals
%    parentIds  - [M X 2] - Parent pair indices
%    crossProb            - Chance of performing crossover
%
% Outputs:
%    children   - [M X N] - New population of M individuals

%------------- BEGIN CODE --------------
%Initialize children matrix by assigning only first individual of all pairs
children = pop(parentIds(:,1) ,:);

for child=1:popSize
    %Should crossover be perform or  not
    % rand(size of vector/matrix)
    crossover_decision = rand(1) < crossProb;
    
    if crossover_decision

       % randi([range], size of vector/matrix)
       cross_point = randi(nGenes-1);
       first_part = pop(parentIds(child,2),1:cross_point);
       second_part = pop(parentIds(child,1),(cross_point+1):end);
       
       %concatenate partA indices/genes with partB indices/genes from pop
       children(child,:) = [first_part second_part];
    end
end
%------------- END OF CODE -------------