function result = calc_fitness(population, coordinates, p)
%% Look up distance for one individual
distMat = squareform(pdist(coordinates')); % Precalculate Distance Matrix
result = NaN([p.popSize 2]);

for index = 1:p.popSize
    ind = population(index,:);
    distance = distMat(ind(1), ind(end));
    for iCity = 2:p.nGenes
        twoCityIndices= [ind(iCity-1), ind(iCity)]; % Indices of distance matrix
        distance = distance + distMat(twoCityIndices(1), twoCityIndices(2));
    end
    result(index, 1) = 1 / (distance + 0.1);
    result(index, 2) = distance;
end