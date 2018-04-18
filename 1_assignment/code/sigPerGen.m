function [p,h] = sigPerGen(A,B, varargin)
%sigPerGen - For each generation of a EA, tests null hypothesis that A and
%B are samples drawn from distributions with equal medians. A and B can
%have different number of runs, but should have the same number of
%generations.
%
% Syntax:  [p,h] = sigPerGen(standardResult,myResult);
%
% Inputs:
%    A      - [runs X gens] - fitness values at each generation in each run
%    B      - [runs X gens] - fitness values at each generation in each run
%  varargin - [string]      - arguments to the ranksum function

% Outputs:
%    p      - [1 X gens] - probability of equal medians per generation
%    h      - [1 X gens] - is p < 0.05? (less than 20% chance same median)
%
% Example: 
%
% Other m-files required: ranksum (Stats & ML toolbox)
%
% See also: ranksum

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 21-Feb-2018

%------------- BEGIN CODE --------------
nGens = size(A,2);
p = nan(1,nGens);
h = nan(1,nGens);

if nargin == 2
    for iGen = 1:nGens
        [p(iGen),h(iGen)] = ranksum(A(:,iGen), B(:,iGen));
    end
else
    % If additional parameters were given
    for iGen = 1:nGens
        [p(iGen),h(iGen)] = ranksum(A(:,iGen), B(:,iGen),varargin{:});
    end
end

if any(isnan(p))
    warning('Identical fitness values in all runs at some generations')
    p(isnan(p)) = 0; 
end

h = logical(h);

%------------- END OF CODE -------------