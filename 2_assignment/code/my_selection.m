function selection = my_selection(fitness, popSize, selection_pressure)
%Selection - Returns indices of parents for crossover
% - Tournament selection:
% Syntax:  parentIds = selection(fitness, p)
%
% Inputs:
%    fitness    - [M X 1] - Fitness of every individual in the population
%    sp                   - Selection Pressure
%
% Outputs:
%    parentIds  - [M X 2] - Indices of each pair of parents

%------------- BEGIN CODE --------------
%Initialize 100x2 matrix of parent indices
selection = randi(popSize,[popSize 2]);
%Get 200 winners and make 100 pairs of them
tournament_group = randi(popSize,[selection_pressure,popSize*2]);
%choose index of max between two rows
[~, winner_index]= max(fitness(tournament_group));
for i=1:length(tournament_group); 
selection(i) = tournament_group(winner_index(i),i);
end

%------------- END OF CODE --------------