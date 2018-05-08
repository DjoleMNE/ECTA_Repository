%% TSP
clear
cityData = importdata('cities.csv');
nCities = 10;
coords = cityData.data([1:nCities], [3 2])'; % <- switch to plot with north up after imagesc
plot(coords(1,:), coords(2,:), 'o')

%% Algorithm Parameters
popSize = 25;
nGenes  = nCities;

%% Create a single individual
% someInd = [1 4 3 2 5 9 8 7 6 10];
% plot(coords(1,someInd), coords(2,someInd),'-o');
% plotTsp(someInd, coords);

%% Create a population
for iPop = 1:popSize
    pop(iPop,:) = randperm(nGenes);
end

%% Calculated Distance of an individual
% distance from last to first city
tic;
ind = pop(1,:);
for i=1:1000
    ind = pop(1,:);
    distance = pdist( coords(:,ind([1 end]) )'  );
    for iCity = 2:nGenes
        twoCityCoords = coords(:,ind([iCity-1:iCity]) );
        distance = distance + pdist( twoCityCoords'); % pDist expects columns to be cities so must transpose twoCityCoords
    end
end
toc
disp(distance)

%% Look up distance for one individual
distMat = squareform(pdist(coords')); % Precalculate Distance Matrix

tic;
ind = pop(1,:);
for i=1:1000
    distance = distMat(ind(1), ind(end));
    for iCity = 2:nGenes
        twoCityIndices= [ind(iCity-1), ind(iCity)]; % Indices of distance matrix
        distance = distance + distMat(twoCityIndices(1), twoCityIndices(2));
    end
end

toc
disp(distance)

%% Crossover
% -- Using set theory to find missing and common values
parentA = 1;
parentB = 2;

% Select a point to split genes
%   Here we do 1 point crossover. Can you think of any advantage of doing
%   '2 point' crossover?
splitPoint = randi(nGenes);
parent1Genes = pop(parentA,[1:splitPoint]);

% Find the values in [1:nCities] that are NOT in parent1Genes
missing = setdiff(1:nCities,parent1Genes);

% Get those missing values in parent2, in the same order ('stable') 
parent2Genes = intersect( pop(parentB,:) ,missing,'stable');

child = [parent1Genes, parent2Genes];

%% Plotting
subplot(2,2,1);
    plotTsp(pop(parentA,:), coords);
    title('ParentA')
subplot(2,2,2);
    plotTsp(pop(parentB,:), coords);
    title('ParentB')
subplot(2,2,[3 4])
    plotTsp(child, coords);
    title('Child')




