%  strfitnessfct = 'frosenbrock';  % name of objective/fitness function
function output = shape_CMA_EP_ES(MaxGen, function_ID, dimension_num)
  nGenes = dimension_num;               % number of objective variables/problem dimension
  xmean = rand(nGenes,1);    % objective variables initial point
  sigma = 0.3;          % coordinate wise standard deviation (step size)
  if function_ID == 1
      stopfitness = 1e-16;  % stop if fitness < stopfitness (minimization)
  elseif function_ID == 2
      stopfitness = 10;  % stop if fitness < stopfitness (minimization)
  else
      stopfitness = 100;
  end

  % Strategy parameter setting: Selection  
  lambda = 4+floor(3*log(nGenes));  % population size, offspring number
  mu = lambda/2;               % number of parents/points for recombination
  weights = log(mu+1/2)-log(1:mu)'; % muXone array for weighted recombination
  mu = floor(mu);        
  weights = weights/sum(weights);     % normalize recombination weights array
  mueff=sum(weights)^2/sum(weights.^2); % variance-effectiveness of sum w_i x_i 


  % Strategy parameter setting: Adaptation
  cc = (4+mueff/nGenes) / (nGenes + 4 + 2*mueff/nGenes);  % time constant for cumulation for C
  cs = (mueff+2) / (nGenes + mueff + 5);  % t-const for cumulation for sigma control
  c1 = 2 / ((nGenes + 1.3)^2 + mueff);    % learning rate for rank-one update of C
  cmu = min(1-c1, 2 * (mueff-2+1/mueff) / ((nGenes + 2)^2 + mueff));  % and for rank-mu update
  damps = 1 + 2*max(0, sqrt((mueff-1)/(nGenes + 1))-1) + cs; % damping for sigma 
                                                      
  % Initialize dynamic (internal) strategy parameters and constants
  pc = zeros(nGenes,1); 
  ps = zeros(nGenes,1);   % evolution paths for C and sigma
  B = eye(nGenes,nGenes);                       % B defines the coordinate system
  D = ones(nGenes,1);                      % diagonal D defines the scaling
  C = B * diag(D.^2) * B';            % covariance matrix C
  invsqrtC = B * diag(D.^-1) * B';    % C^-1/2 
  eigeneval = 0;                      % track update of B and D
  chiN = nGenes^0.5*(1-1/(4*nGenes)+1/(21*nGenes^2));  % expectation of 
                                      %   ||N(0,I)|| == norm(randn(N,1)) 
  % -------------------- Generation Loop --------------------------------
  counteval = 0;  
  num_gen = MaxGen;
  min_fitness = zeros(MaxGen,1);
  median_fitness = zeros(MaxGen,1);

for gen = 1:num_gen
      % Generate and evaluate lambda offspring
%       fitness = zeros(lambda,1);
%       x = zeros(nGenes, lambda);
      
      for k=1:lambda
          x(:,k) = xmean + sigma * B * (D .* randn(nGenes,1)); % m + sig * Normal(0,C) 
          if function_ID == 1
              if dimension_num == 2
                  fitness(k) = frosen2D(x(:,k));
              else
                  fitness(k) = frosen12D(x(:,k)); 
              end
          elseif function_ID == 2
              if dimension_num == 2
                  fitness(k) = frastrigin2D(x(:,k));
              else
                  fitness(k) = frastrigin12D(x(:,k));
              end
          else
              fitness(k) = oneHundredDfunction(x(:,k));
          end
          counteval = counteval + 1;
      end
    
      % Sort by fitness and compute weighted mean into xmean
      [fitness, index] = sort(fitness); % minimization
      min_fitness(gen,1) = min(fitness);
      median_fitness(gen,1) = median(fitness);
      xold = xmean;
      xmean = x(:,index(1:mu))* weights;   % recombination, new mean value
    
     ps = (1-cs)*ps ... 
        + sqrt(cs*(2-cs)*mueff) * invsqrtC * (xmean-xold) / sigma; 
     hsig = norm(ps)/sqrt(1-(1-cs)^(2*counteval/lambda))/chiN < 1.4 + 2/(nGenes+1);
     pc = (1-cc)*pc ...
        + hsig * sqrt(cc*(2-cc)*mueff) * (xmean-xold) / sigma;

      % Adapt covariance matrix C
    artmp = (1/sigma) * (x(:,index(1:mu))-repmat(xold,1,mu));
    C = (1-c1-cmu) * C ...                  % regard old matrix  
       + c1 * (pc*pc' ...                 % plus rank one update
               + (1-hsig) * cc*(2-cc) * C) ... % minor correction if hsig==0
       + cmu * artmp * diag(weights) * artmp'; % plus rank mu update

    % Adapt step size sigma
    sigma = sigma * exp((cs/damps)*(norm(ps)/chiN - 1)); 

    % Decomposition of C into B*diag(D.^2)*B' (diagonalization)
    if counteval - eigeneval > lambda/(c1+cmu)/nGenes/10  % to achieve O(N^2)
      eigeneval = counteval;
      C = triu(C) + triu(C,1)'; % enforce symmetry
      [B,D] = eig(C);           % eigen decomposition, B==normalized eigenvectors
      D = sqrt(diag(D));        % D is a vector of standard deviations now
      invsqrtC = B * diag(D.^-1) * B';
    end
    if fitness(1) <= stopfitness || max(D) > 1e7 * min(D)
       break;
    end
    xmin = x(:, index(1));
end
output.fitMax   = min_fitness;
output.fitMed   = median_fitness;
output.best_individual = xmin;
end
