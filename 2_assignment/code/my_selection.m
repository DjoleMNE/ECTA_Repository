function parentIds = my_selection(fitness, popSize, sp)
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
parentIds = NaN([popSize 2]);

%Get 200 winners and make 100 pairs of them
for i=1:popSize*2
    for k=1:2         
        %Get random indeces of individuals.
        %Syntax: range, [size of matrix]
        randomPair = randi(popSize,[sp,1]);
        
        %choose index of max between two rows
        [winner_value, winner_index]= max(fitness(randomPair));
        
        %Fill out parentIds matrix...syntax for matrix(i):
        %goes over whole first row, than over  whole second row, and so on.
        %Fill 100x2 matrix -> 100 pairs of 200 parents.
        parentIds(i) = randomPair(winner_index);
    end
end
%------------- END OF CODE --------------