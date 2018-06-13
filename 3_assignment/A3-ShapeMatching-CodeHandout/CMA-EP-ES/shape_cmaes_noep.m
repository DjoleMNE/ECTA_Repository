%  strfitnessfct = 'frosenbrock';  % name of objective/fitness function
function output = shape_cmaes_noep(MaxGen)
  nGenes = 32;               % number of objective variables/problem dimension
  xmean = rand(nGenes,1);    % objective variables initial point
  sigma = 0.1;          % coordinate wise standard deviation (step size)
  stopfitness = 1e-10;  % stop if fitness < stopfitness (minimization)
  stopeval = 1e3*nGenes^2;   % stop after stopeval number of function evaluations
  
  numEvalPts = 256;                           % Num evaluation points
  nacaNum = [5,5,2,2];                        % NACA Parameters
  nacafoil= create_naca(nacaNum,numEvalPts); % Create foil
  % Strategy parameter setting: Selection  
  lambda = 4+floor(3*log(nGenes));  % population size, offspring number
  mu = lambda/2;               % number of parents/points for recombination
  weights = log(mu+1/2)-log(1:mu)'; % muXone array for weighted recombination
  mu = floor(mu);        
  weights = weights/sum(weights);     % normalize recombination weights array
  mueff=sum(weights)^2/sum(weights.^2); % variance-effectiveness of sum w_i x_i
  gamma = (20/17)^(1/nGenes);
  


  % Strategy parameter setting: Adaptation

    c1 = 2 / ((nGenes + 1.3)^2 + mueff);    % learning rate for rank-one update of C
    cmu = min(1-c1, 2 * (mueff-2+1/mueff) / ((nGenes + 2)^2 + mueff));  % and for rank-mu update
%                                                       
  % Initialize dynamic (internal) strategy parameters and constants
  B = eye(nGenes,nGenes);                       % B defines the coordinate system
  D = ones(nGenes,1);                      % diagonal D defines the scaling
  C = B * diag(D.^2) * B';            % covariance matrix C
  eigeneval = 0;                      % track update of B and D
  % -------------------- Generation Loop --------------------------------
  counteval = 0;  
  num_gen = MaxGen;
  max_fitness = zeros(MaxGen,1);
  median_fitness = zeros(MaxGen,1);

for gen = 1:num_gen
      % Generate and evaluate lambda offspring
      for k=1:lambda,
          x(:,k) = xmean + sigma * B * (D .* randn(nGenes,1)); % m + sig * Normal(0,C) 
          fitness(k) = shape_cmaes_fitness(x(:,k),nacafoil,numEvalPts);
          counteval = counteval+1;
      end
    
      % Sort by fitness and compute weighted mean into xmean
      [fitness, index] = sort(fitness,'descend'); % minimization
      max_fitness(gen,1) = max(fitness);
      median_fitness(gen,1) = median(fitness);
      xmean = x(:,index(1:mu))* weights;   % recombination, new mean value
      
      best_individual = x(:,index(1:mu));
    
      
%      ps = (1-cs)*ps ... 
%         + sqrt(cs*(2-cs)*mueff) * invsqrtC * (xmean-xold) / sigma; 
%      hsig = norm(ps)/sqrt(1-(1-cs)^(2*counteval/lambda))/chiN < 1.4 + 2/(nGenes+1);
%      pc = (1-cc)*pc ...
%         + hsig * sqrt(cc*(2-cc)*mueff) * (xmean-xold) / sigma;

      % Adapt covariance matrix C
 %   y = x(:,index(1:mu))/ sigma;
     C = (1-cmu)* C + rank_mu_update(best_individual, xmean, weights,nGenes,cmu,sigma,mu)

     sigma = sigma/gamma;

    % Decomposition of C into B*diag(D.^2)*B' (diagonalization)
    if counteval - eigeneval > lambda/(c1+cmu)/nGenes/10  % to achieve O(N^2)
      eigeneval = counteval;
      C = triu(C) + triu(C,1)'; % enforce symmetry
      [B,D] = eig(C);           % eigen decomposition, B==normalized eigenvectors
      D = sqrt(diag(D));        % D is a vector of standard deviations now
      %invsqrtC = B * diag(D.^-1) * B';
    end
    if fitness(1) <= stopfitness || max(D) > 1e7 * min(D)
       break;
    end
    xmin = x(:, index(1));
    individual = xmin ; 
    [foil, nurbs] = pts2ind(individual,numEvalPts);
    % Visualize
    figure(1);
    plot(nacafoil(1,:),nacafoil(2,:), 'LineWidth', 3);
    hold on;
    plot(foil(1,:),foil(2,:), 'r', 'LineWidth', 3);
    %plot(nurbs.coefs(1,1:end/2),nurbs.coefs(2,1:end/2),'rx', 'LineWidth', 3);
    plot(nurbs.coefs(1,:),nurbs.coefs(2,:),'ko', 'LineWidth', 3);
    axis equal;
    axis([0 1 -0.7 0.7]);
    %     legend('NACA 0012 target', 'Approximated Shape');
    ax = gca;
    ax.FontSize = 24;
    drawnow;
    hold off;
end
output.fitMax   = max_fitness;
output.fitMed   = median_fitness;
end
