function [fitness, xmean] = CMA_ES_EP(wing_type)  % (mu/mu_w, lambda)-CMA-ES
    % --------------------  Initialization --------------------------------
    % Wing Parameters
    n_param.numEvalPts = 256;
    switch wing_type
        case 1
            n_param.nacaNum = [0,0,1,2];
            %                 disp('Wing 1')
        case 2
            n_param.nacaNum = [5,5,2,2];
            %                 disp('Wing 2')
        case 3
            n_param.nacaNum = [9,7,3,5];
            %                 disp('Wing 3')
        otherwise
            n_param.nacaNum = [0,0,1,2];
            %                 disp('Wing 1')
    end
    n_param.nacafoil= create_naca(n_param.nacaNum,n_param.numEvalPts);  % Create foil

    %Aplication parameters
    strfitnessfct = 'fitness_meansquare';  % name of objective/fitness function
    N = 32;               % number of objective variables/problem dimension
    xmean = rand(N,1)-0.5;    % objective variables initial point
    sigma = 0.3;          % coordinate wise standard deviation (step size)
    stopfitness = 1e-5;  % stop if fitness < stopfitness (minimization)
    stopeval = 1001;   % stop after stopeval number of function evaluations

    % Strategy parameter setting: Selection
    lambda = 4+floor(3*log(N));  % population size, offspring number
    mu = lambda/2;               % number of parents/points for recombination
    weights = log(mu+1/2)-log(1:mu)'; % muXone array for weighted recombination
    mu = floor(mu);
    weights = weights/sum(weights);     % normalize recombination weights array
    mueff=sum(weights)^2/sum(weights.^2); % variance-effectiveness of sum w_i x_i

    % Strategy parameter setting: Adaptation
    cc = (4+mueff/N) / (N+4 + 2*mueff/N);  % time constant for cumulation for C (for the evolution path)
    cs = (mueff+2) / (N+mueff+5);  % t-const for cumulation for sigma control (takes care of some error)
    c1 = 2 / ((N+1.3)^2+mueff);    % learning rate for rank-one update of C
    cmu = min(1-c1, 2 * (mueff-2+1/mueff) / ((N+2)^2+mueff));  % and for rank-mu update
    damps = 1 + 2*max(0, sqrt((mueff-1)/(N+1))-1) + cs; % damping for sigma
    % usually close to 1
    % Initialize dynamic (internal) strategy parameters and constants
    pc = zeros(N,1);
    ps = zeros(N,1);   % evolution paths for C and sigma
    B = eye(N,N);                       % B defines the coordinate system
    D = ones(N,1);                      % diagonal D defines the scaling
    C = B*diag(D.^2)*B';            % covariance matrix C
    invsqrtC = B * diag(D.^-1) * B';    % C^-1/2
    %   eigeneval = 0;                      % track update of B and D
    chiN=N^0.5*(1-1/(4*N)+1/(21*N^2));  % expectation of

    % -------------------- Generation Loop --------------------------------
    counteval = 1;  % the next 40 lines contain the 20 lines of interesting code
    iFit = 1;
    while counteval < stopeval

        % Generate and evaluate lambda offspring
        for k=1:lambda
            arz(:,k) = randn(N,1);
            new_value = xmean + sigma * B * (D .* arz(:,k) ); % m + sig * Normal(0,C)
            new_value(new_value > 0.5) = 0.5;
            new_value(new_value < -0.5) = -0.5;
            arx(:,k) = new_value;
            foil = pts2ind(arx(:,k), n_param.numEvalPts);
            arfitness(k) = feval(strfitnessfct, n_param, foil); % objective function call
        end
        
        

        % Sort by fitness and compute weighted mean into xmean
        [arfitness, arindex] = sort(arfitness); % minimization
        xold = xmean;

        %Updating mean
        xmean = arx(:,arindex(1:mu))*weights;   % recombination, new mean value

        % Cumulation: Update evolution paths
        ps = (1-cs)*ps ...
            + sqrt(cs*(2-cs)*mueff) * invsqrtC * (xmean-xold) / sigma;
        hsig = norm(ps)/sqrt(1-(1-cs)^(2*counteval/lambda))/chiN < 1.4 + 2/(N+1);
        pc = (1-cc)*pc ...
            + hsig * sqrt(cc*(2-cc)*mueff) * (xmean-xold) / sigma;

        % Adapt covariance matrix C
        artmp = (1/sigma) * (arx(:,arindex(1:mu))-repmat(xold,1,mu));
        C = (1-c1-cmu) * C ...                  % regard old matrix
            + c1 * (pc*pc' ...                 % plus rank one update
            + (1-hsig) * cc*(2-cc) * C) ... % minor correction if hsig==0
            + cmu * artmp * diag(weights) * artmp'; % plus rank mu update

        %  Adapt step size sigma
        sigma = sigma * exp((cs/damps)*(norm(ps)/chiN - 1));

        % Decomposition of C into B*diag(D.^2)*B' (diagonalization)
        C = triu(C) + triu(C,1)'; % enforce symmetry
        [B,D] = eig(C);           % eigen decomposition, B==normalized eigenvectors
        D = sqrt(diag(D));        % D is a vector of standard deviations now
        invsqrtC = B * diag(D.^-1) * B';
%         plot_foil(xmean, wing)
        foil = pts2ind(xmean, n_param.numEvalPts);
        fitness(iFit) = feval(strfitnessfct, n_param, foil);


        % Break, if fitness is good enough or condition exceeds 1e14, better termination methods are advisable
%         if arfitness(1) <= stopfitness || max(D) >1e7 * min(D)
%             return;
%         end
%         disp([num2str(counteval) ': ' num2str(arfitness(1))]);
        iFit = iFit +1;
        counteval = counteval+1;



    end

end
