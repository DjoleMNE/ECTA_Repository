%%TSP
%% Algorithm parameters
popSize = 25;
nGenes = nCities

for iPop = 1:popSize
    pop(iPop,:)= randperm(nGenes);
end

cityData = importdata('cities.csv');
nCities = 10;
coords = cityData.data([1:nCities], [3 2]);
plot(coords(1,:), coords(2,:),'o')

%% Create a single induvidual
someInd = [1 4 3 2 5 9 8 7 6 10];
plot(coords(1,someInd),coords(2,someInd), '-o');
plotTsp(someInd , coords);


%% Distance of path?
%%Distance from last to first city
distance = pdist(coords,(:,someInd([1 end])'))

for iCity = 2:nCities
    distance = distance+pdist(coords(:,someInd([iCity iCity-1])'));
end


%% Look up distance for induvidual
distMat = squareform(pdist(coords'))
ind = pop(1,:)
distance = distMat(ind(1), ind(end));
for iCity = 2:nCities
    distance = distance + disMat(ind(iCity-1), ind(iCity));
end
disp(distance)
