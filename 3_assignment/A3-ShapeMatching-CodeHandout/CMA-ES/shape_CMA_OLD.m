function output = shape_CMA_ES(nacafoil, numEvalPts)
%Code partialy based on:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple matlab/octave implementation of the CMA-ES as discussed in
% http://www.scholarpedia.org/article/Evolution_Strategies   
% The code presented below should be regarded as a skeleton only 
% Note, the code presented is to be used under GNU General Public License
% Author: Hans-Georg Beyer   
% Email: Hans-Georg.Beyer_AT_fhv.at
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% definition of the specific strategy and problem size:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p.nGenes = 32;
p.popSize = 1;
mu = 3;                                 % number of parents
lambda = 12;                            % number of offspring
VarMin=-0.5;             % Lower Bound of Decision Variables
VarMax= 0.5;             % Upper Bound of Decision Variables
yInit = unifrnd(VarMin,VarMax, p.popSize, p.nGenes);% initial parent vector 
sigmaInit = 1;                          % initial global mutation strength sigma 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = p.nGenes;      % determine search space dimensionality n   
tau = sqrt(n); 
tau_c = n^2; 
tau_sigma = sqrt(n); % time constants
Cov = eye(n);           % initial covariance matrix 
sigma = sigmaInit;      % initial sigma
s = zeros(n,1);         % set cumulation vector to zero
s_sigma = zeros(n,1);   % set cumulation vector to zero

% initializing individual population:
Individual.y = yInit; 
Individual.w = 0;
Individual.std = 0;
%Individual.F = example_calc_fitness(Individual.y);
[value, matrix] = shape_calc_fitness(Individual.y, nacafoil, numEvalPts, p);   
Individual.F = value;
Individual.foil = matrix;

ParentPop = cell(p.popSize, 1);

for i=1:mu
    ParentPop{i} = Individual; 
end

yParent = yInit;        % initial centroid parent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% evolution loop of the CMA-ES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
count = 0;
while(count < 7000)
    
    % If Covariance Matrix is not Positive Defenite or Near Singular
    [V, E] = eig(Cov);
    if any(diag(E) < 0)
        disp("Here")
        E = max(E, 0);
        Cov = V * E/V;
    end
    
    SqrtCov = chol(Cov)';                    % "square root" of covariance matrix
    OffspringPop = cell(lambda, 1);
    
    for l = 1:lambda                        % generate lambda offspring
        for index = 1:p.nGenes    
            OffspringIndividual.std = randn(1, n);    % line (L1a)
            OffspringIndividual.w(index) = sigma * (SqrtCov(index, :) * OffspringIndividual.std'); % line (L1a)
            temp = yParent(index) + OffspringIndividual.w(index);         % line (L1b)
           
            while temp > 0.5 || temp < -0.5
                OffspringIndividual.std = randn(1, n);   % line (L1a)
                OffspringIndividual.w(index) = sigma * (SqrtCov(index, :) * OffspringIndividual.std'); % line (L1a)
                temp = yParent(index) + OffspringIndividual.w(index);         % line (L1b)
            end
            
            OffspringIndividual.y(index) = temp;
        end
        
%         OffspringIndividual.std = randn(1, n);   % line (L1a)
%         OffspringIndividual.w = sigma * (SqrtCov * OffspringIndividual.std'); % line (L1a)
%         
%         OffspringIndividual.y = yParent + OffspringIndividual.w';         % line (L1b)
        [value, matrix] = shape_calc_fitness(OffspringIndividual.y, ...
                                             nacafoil, ...
                                             numEvalPts, p);   
        OffspringIndividual.F = value;  % determine fitness (L1c)
        OffspringIndividual.foil = matrix;
        OffspringPop{l} = OffspringIndividual;                   % offspring complete
    end
    
    ParentPop = sort_pop(OffspringPop, mu);   % sort population and take mu best
    %disp(ParentPop{1}.F);                    % display best fitness in population
    
    Recombinant = cma_es_recombination(ParentPop); % (L2) perform recombination 
    yParent = yParent + Recombinant.w';       % (L2) calculate new centroid parent
    
    s = (1-1/tau)*s + sqrt(mu/tau*(2-1/tau))*Recombinant.w/sigma;   % line (L3)
    
    Cov = (1-1/tau_c)*Cov + (s/tau_c)*s';                           % line (L4)
    
    Cov = (Cov + Cov')/2;                    % enforce symmetry of cov matrix
    s_sigma = (1-1/tau_sigma)*s_sigma + sqrt(mu/tau_sigma*(2-1/tau_sigma)) * Recombinant.std'; % line (L5)
    
    sigma = sigma*exp((s_sigma'*s_sigma - n)/(2*n*sqrt(n)));        % line (L6)
    
    %disp(count)
    count = count + 1; 
end

%% Setting outputs
output.best = ParentPop{1}.y;
output.best_foil = ParentPop{1}.foil;
