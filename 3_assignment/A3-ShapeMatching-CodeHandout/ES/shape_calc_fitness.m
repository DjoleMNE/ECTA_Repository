function [result, foils] = shape_calc_fitness(population, nacafoil, numEvalPts, p)
%% Look up distance for one individual
% distMat = squareform(pdist(coordinates')); % Precalculate Distance Matrix
result = NaN([p.popSize 1]);
foils = NaN([2 numEvalPts p.popSize]);

%% Compute mean square error - MSE
for index = 1:p.popSize
    % Extract spline representation of a foil 
    % (with the same number of evaluation  points as the NACA profile)
    individual = population(index, :)';

    [foil, ~] = pts2ind(individual, numEvalPts);
    foils(:, :, index) = foil;
    
    % Calculate pairwise error
    [~,errorTop] = dsearchn(nacafoil(:, 1:end/2)', foil(:, 1:end/2)');
    [~,errorBottom] = dsearchn(nacafoil(:, 1+end/2:end)', foil(:, 1+end/2:end)');

    % Total fitness (mean squared error)
    fitness = mean([errorTop.^2; errorBottom.^2]);
    result(index, 1) = 1 / (fitness + 0.01) ; 
end 

% for index = 1:p.popSize
%     result(index, 2) = sum( value( logical( population( index, :))));
%     result(index, 3) = sum( weight( logical(population( index, :))));
% %     result(index, 1) = result(index, 2) - result(index, 3)/1.5;
% %     
% %     if result(index, 3) > 310
% %        result(index, 1) = 0;
% %     end
%     penalty = result(index, 3) - 300;                    
%     penalty(penalty < 0) = 0;   
%     result(index, 1) = result(index, 2) - penalty; 
% end 

%% Get penalty by checking colors for all neighbours of all nodes
% The penalty is increased for every edge that connects same colored nodes.
% for index = 1:p.popSize
%     penalty = 0;
%     
%     for node = 1:size(adjacency, 1)
%         for neigh=find(adjacency(node, :) == 1)
%             if population(index, node) == population(index, neigh)
%                 penalty = penalty + 1;
%             end
%         end
%     end
%     
%     temp_result = 100 / (penalty + 0.1);
%     result(index) = temp_result;    
% end

% for index = 1:p.popSize
%     ind = population(index,:);
%     distance = distMat(ind(1), ind(end));
%     for iCity = 2:p.nGenes
%         twoCityIndices= [ind(iCity-1), ind(iCity)]; % Indices of distance matrix
%         distance = distance + distMat(twoCityIndices(1), twoCityIndices(2));
%     end
%     result(index, 1) = 1 / (distance + 0.1);
%     result(index, 2) = distance;
% end