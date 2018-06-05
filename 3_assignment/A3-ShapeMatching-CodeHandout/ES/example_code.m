%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a simple Octave implementation of the (mu/mu_I, lambda)-sigmaSA-ES
% as discussed in 
% http://www.scholarpedia.org/article/Evolution_Strategies
% Note, if you want to use this in Matlab, you have to copy each function
% definition in a separate m-file.
% The code presented below should be regarded as a skeleton only            
% Note, the code presented is to be used under GNU General Public License   
% Author: Hans-Georg Beyer                                                  
% Email: Hans-Georg.Beyer_AT_fhv.at                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function to be optimized (sphere test function as an example, to be changed):
function out = fitness(x); out = sum(x.*x); end

% this sorts the population according to the individuals' fitnesses:
function sorted_pop = SortPop(pop, mu);
 for i=1:length(pop); fitnesses(i) = pop{i}.F; end;
 [sorted_fitnesses, index] = sort(fitnesses);
 for i=1:mu; sorted_pop{i} = pop{index(i)}; end
end

% this performs intermediate (multi-) recombination: 
function r = recombine(pop);
 r.sigma = 0; r.y = 0; 
 for i=1:length(pop); 
  r.sigma = r.sigma + pop{i}.sigma; r.y = r.y + pop{i}.y; 
 end;
 r.sigma = r.sigma/length(pop); r.y = r.y/length(pop);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here comes the ES example:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mu = 3;                 % number of parents
lambda = 12;            % number of offspring
yInit = ones(30,1);     % initial parent vector 
sigmaInit = 1;          % initial global mutation strength sigma 
sigmaMin = 1e-10;       % ES stops when sigma is smaller than sigmaMin

% initialization:
n = length(yInit);      % determine search space dimensionality n   
tau = 1/sqrt(2*n);      % self-adaptation learning rate
% initializing individual population:
Individual.y = yInit;
Individual.sigma = sigmaInit;
Individual.F = fitness(Individual.y);
for i=1:mu; ParentPop{i} = Individual; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evolution loop of the (mu/mu_I, lambda)-sigma-SA-ES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while(1)
 Recombinant = recombine(ParentPop);              % recombine parents
 for l = 1:lambda;                                % generate lambda offspring
  OffspringIndividual.sigma = Recombinant.sigma * exp(tau*randn); % mutate sigma
  OffspringIndividual.y = Recombinant.y + OffspringIndividual.sigma * randn(n, 1); % mutate object parameter
  OffspringIndividual.F = fitness(OffspringIndividual.y); % determine fitness
  OffspringPop{l} = OffspringIndividual;                  % offspring complete
 end;
 ParentPop = SortPop(OffspringPop, mu);   % sort population
 disp(ParentPop{1}.F);                    % display best fitness in population
 if ( ParentPop{1}.sigma < sigmaMin ) break; end; % termination criterion
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Remark: Final approximation of the optimizer is in "ParentPop{1}.y"
%         corresponding fitness is in "ParentPop{1}.F" and the final 
%         mutation strength is in "ParentPop{1}.sigma"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

