function children = shape_matching_crossover(pop, parentIds, p)
%Crossover - Creates child solutions by combining genes of parents

children = pop(parentIds(:,1), :);

% for child=1:p.popSize
%     %Should crossover be perform or  not
%     % rand(size of vector/matrix)
%     crossover_decision = rand(1) < p.crossProb;
%     
%     if crossover_decision
% 
%        % randi([range], size of vector/matrix)
%        cross_point = randi(p.nGenes-1);
%        first_part = pop(parentIds(child,2),1:cross_point);
%        second_part = pop(parentIds(child,1),(cross_point+1):end);
%        
%        %concatenate partA indices/genes with partB indices/genes from pop
%        children(child,:) = [first_part second_part];
%     end
% end

%% Crossover
% -- Using set theory to find missing and common values
% Select a point to split genes
%   Here we do 1 point crossover. Can you think of any advantage of doing
%   '2 point' crossover?
% for child = 1:p.popSize
%     if rand() < p.crossProb
%         indexA = parentIds(child, 1);
%         indexB = parentIds(child, 2);
%         
%         crossPt1 = randi(p.nGenes - 1);
%         crossPt2 = randi([crossPt1 + 1 p.nGenes]); 
%         
%         parentA = pop([indexA, crossPt1:crossPt2]);
%         missing_parents = setdiff(1:p.nGenes, parentA);
% 
%         % Get those missing values in parentB, in the same order ('stable') 
%         parentB = intersect(pop(indexB,:), missing_parents, 'stable');
% 
%         children(child,:) = [parentA, parentB];
%     end
% end

%% Single point crossover
doXover = (rand(1,p.popSize) < p.crossProb);            % Crossover or not?
crossPt = randi([1 p.nGenes-1],1,p.popSize) .* doXover; % Get Crossover Pts

for iChild = 1:p.popSize
  partA = 1:crossPt(iChild);
  partB = 1+crossPt(iChild) : size(pop,2);
  children(iChild,:) = ...
       [pop(parentIds(iChild,1), partA), pop(parentIds(iChild,2), partB)];
       %mean(partA,partB);
end

