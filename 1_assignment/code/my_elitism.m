function eliteIds = my_elitism(fitness, p)
%Elitism - Get indices of individual(s) to continue unchanged into next pop
% - Standard Elitism:
%   1) Find 1 best performing individual
%   * Optional: In very large populations select a top percentage
%
% Syntax:  eliteId   = my_elitism(fitness, p)
%
% Inputs:
%    fitness    - [M X 1] - Fitness of every individual in the population
%    p          - _struct - Hyperparameter struct
%     .elitePercent         - Percentage of pop to take as elites (min 1)
%
% Outputs:
%    eliteIds   - [nElites X 1] - Indices of each elite
%
%
% See also: selection, crossover, mutation, monkeyGa

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------

%% Here we just keep the first individual as an elite, can you do better?
eliteIds = 1;

%------------- END OF CODE --------------