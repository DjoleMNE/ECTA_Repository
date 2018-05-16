clear
cityData = importdata('cities.csv');
nCities = 10;
coords = cityData.data([1:nCities], [3 2])'; % <- switch to plot with north up after imagesc %[1:10] row no [3 then 2]
plot(coords(1,:), coords(2,:), 'o');
pdist(coords')

%% Algorithm Parameters
popSize = 25;
nGenes  = nCities;
selection_pressure = 2;
elitePerc = 0.1
mutProb = 1/nGenes

children = [2,4,7,3,5,6,10,9,8,1]
for iPop = 1:popSize
    pop(iPop,:) = randperm(nCities)
end

