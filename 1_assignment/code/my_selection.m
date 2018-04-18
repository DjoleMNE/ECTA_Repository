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

parentIds = NaN([p.popSize 2]);

%Get random indeces of individuals...matrix 2x200
%range, [size of matrix]
tGroups = randi(p.popSize, [p.sp p.popSize*2]); % Make tournament groups

%choose max over columns -> for each column chose max row 
[~,iWinner] = max(fitness(tGroups));            % Get 200 Winners

%Fill out patentIds matrix...syntax for matrix(i):
%goes over whole first row,
%than over  whole second row, and so on, until the end.
%Fill 2x100 matrix - > 100 pairs of parents ready for crossover
for i=1:length(tGroups)
    parentIds(i) = tGroups(iWinner(i),i);
end 
%------------- END OF CODE --------------