function children = shape_crossover(pop, parentIds, p)
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
children = pop(parentIds(:, 1), :);

% One point crossover
% for child=1:p.popSize
%     %Should crossover be perform or  not
%     % rand(size of vector/matrix)
%     crossover_decision = rand(1) < p.crossProb;
%     
%     if crossover_decision
% 
%        % randi([range], size of vector/matrix)
%        cross_point = randi(p.nGenes - 1);
%        first_part = pop(parentIds(child, 2), 1:cross_point);
%        second_part = pop(parentIds(child, 1), (cross_point + 1):end);
%        
%        %concatenate partA indices/genes with partB indices/genes from pop
%        children(child,:) = [first_part second_part];
%     end
% end

% -- Using set theory to find missing and common values
% Select a point to split genes
%   Here we do 1 point crossover. Can you think of any advantage of doing
%   '2 point' crossover?
% for child = 1:p.popSize
%     
%     splitPoint = randi(p.nGenes - floor(10 - 10 * p.crossProb));
%     parentA = pop(child, 1:splitPoint);
% 
%     % Find the values in [1:nCities] that are NOT in parent1Genes
%     missing = setdiff(1:p.nCities, parentA);
% 
%     % Get those missing values in parentB, in the same order ('stable') 
%     parentB = intersect(pop(child,:), missing,'stable');
%     
%     children(child,:) = [parentA, parentB];
% end

% Two point crossover
for child = 1:p.popSize
    if rand() < p.crossProb
        
        % Select current parent ids
        indexA = parentIds(child, 1);
        indexB = parentIds(child, 2);

        % Select points to split genes
        splitPointA = randi(p.nGenes-1);
        splitPointB = randi([(splitPointA + 1) p.nGenes]);

        parent1Genes = pop(indexA, splitPointA:splitPointB);

        if splitPointA == 1
            if splitPointB == p.nGenes
                continue;
            end
            parent2Genes = pop(indexB, (splitPointB + 1):p.nGenes);
            children(child,:) = [parent1Genes, parent2Genes];
            
        else
            if splitPointB == p.nGenes
                parent2Genes = pop(indexB, 1:(splitPointA - 1));
                children(child,:) = [parent2Genes, parent1Genes];
            else
                parent2Genes_1 = pop(indexB, 1:(splitPointA -1));
                parent2Genes_2 = pop(indexB, (splitPointB + 1):p.nGenes);
                children(child,:) = [parent2Genes_1,...
                                    parent1Genes,...
                                    parent2Genes_2];
            end
        end        
    end
end
%------------- END OF CODE -------------