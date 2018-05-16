function fitness = calc_fitness(pop, popSize, coords,nCities)
fitness = NaN([popSize 2]);
%% Calculated Distance of an individual
% distance from last to first city

for i=1:25
    ind = pop(i,:);
    distance = pdist( coords(:,ind([1 end]) )');
    for iCity = 2:nCities
        twoCityCoords = coords(:,ind([iCity-1:iCity]));
        distance = distance + pdist( twoCityCoords'); % pDist expects columns to be cities so must transpose twoCityCoords
    end
fitness(i,2) = distance;
fitness(i,1) = 1/(distance+0.1);
end

