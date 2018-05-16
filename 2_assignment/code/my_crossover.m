function children = my_crossover(pop, selection, popSize, nGenes, crossProb)
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
%% Crossover
children = pop(selection(:,1), :);

parent1 = pop(selection,:)

for child = 1:popSize
    % Select a point to split genes
    %   Here we do 1 point crossover. Can you think of any advantage of doing
    %   '2 point' crossover?
    splitPoint = randi(nGenes);
    parent1Genes = pop(1,[1:splitPoint]);

    % Find the values in [1:nCities] that are NOT in parent1Genes
    missing = setdiff(1:nGenes,parent1Genes);

    % Get those missing values in parent2, in the same order ('stable') 
    parent2Genes = intersect(pop(2,:), missing,'stable');

    children(child,:) = [parent1Genes, parent2Genes];
end
%------------- END OF CODE -------------