function parentIds = my_selection(fitness, p)
%Selection - Returns indices of parents for crossover
% - Tournament selection:
%   1) N individuals are chosen randomly (N is selection pressure)
%   2) The individual in this subset with the highest fitness is chosen as
%   a parent
%   3) Another N individuals are chosen randomly
%   4) The individual in this subset with the highest fitness is chosen as
%   the other parent
%   5) Repeat steps 1-4 until you have one _pair_ of parents for each child
%   you plan on producing.
%
% Syntax:  parentIds = selection(fitness, p)
%
% Inputs:
%    fitness    - [M X 1] - Fitness of every individual in the population
%    p          - _struct - Hyperparameter struct
%     .sp                   - Selection Pressure
%
% Outputs:
%    parentIds  - [M X 2] - Indices of each pair of parents
%
% See also: crossover, mutation, elitism, monkeyGa

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------
%Initialize 100x2 matrix of parent indices
parentIds = NaN([p.popSize 2]);

%Get 200 winners and make 100 pairs of them
for i=1:p.popSize*2
    for k=1:2 
        
        %Get random indeces of individuals.
        %Syntax: range, [size of matrix]
        randomPair = randi(p.popSize,[2,1]);
        
        %choose index of max between two rows
        [winner_value, winner_index]= max(fitness(randomPair));
        
        %Fill out parentIds matrix...syntax for matrix(i):
        %goes over whole first row, than over  whole second row, and so on.
        %Fill 100x2 matrix -> 100 pairs of 200 parents ready for crossover.
        parentIds(i) = randomPair(winner_index);
    end
end
%------------- END OF CODE --------------