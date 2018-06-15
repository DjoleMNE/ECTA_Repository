function [fitness, xmean] = CMA_ES(wing_type)   % (mu/mu_w, lambda)-CMA-ES
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
    task = 'fitness_meansquare';  % name of objective/fitness function
    N = 32;               % number of objective variables/problem dimension
    xmean = rand(N,1)-0.5;    % objective variables initial point
    sigma = 0.2;          % coordinate wise standard deviation (step size)
    stopfitness = 1e-5;  % stop if fitness < stopfitness (minimization)
    stopeval = 1001;   % stop after stopeval number of function evaluations

    % Strategy parameter setting: Selection
    lambda = 4+floor(3*log(N));  % population size, offspring number
    mu = lambda/2;               % number of parents/points for recombination
    weights = log(mu+1/2)-log(1:mu)'; % muXone array for weighted recombination
    mu = floor(mu);
    weights = weights/sum(weights);     % normalize recombination weights array
    mueff=sum(weights)^2/sum(weights.^2); % variance-effectiveness of sum w_i x_i
    gamma = (20/17)^(1/N);

    % Rank-1 update parameter
    c1 = 2 / ((N+1.3)^2+mueff);    % learning rate for rank-one update of C

    %Initializing Matrix for the cov decomposition
    B = eye(N);                       % B defines the coordinate system
    D = eye(N);                      % diagonal D defines the scaling
    C = B*D*(B*D)';            % covariance matrix C

    % --------------------  Iteration --------------------------------
    counteval = 1;
    iFit = 1;
    while counteval < stopeval

        % Generate and evaluate lambda offspring
        for k=1:lambda
            arz(:,k) = randn(N,1);
            new_value = xmean + sigma * (B * D * arz(:,k) ); % m + sig * Normal(0,C)
            new_value(new_value > 0.5) = 0.5;
            new_value(new_value < -0.5) = -0.5;
            arx(:,k) = new_value;
            foil = pts2ind(arx(:,k), n_param.numEvalPts);
            arfitness(k) = feval(task, n_param, foil); % objective function call
        end
        
        % Sort by fitness and compute weighted mean into xmean
        [arfitness, arindex] = sort(arfitness); % minimization

        %Covariance Matrix
        y = (arx(:,arindex(1))-xmean)/sigma;
        C = ((1-c1)*C) + (c1*(y*y'));

        %Updating mean
        xmean = arx(:,arindex(1:mu))*weights;   % recombination, new mean value


        % Decomposition of C into B*diag(D.^2)*B' (diagonalization)
        C = triu(C) + triu(C,1)'; % enforce symmetry
        [B,D] = eig(C);           % eigen decomposition, B==normalized eigenvectors
        D = diag(sqrt(diag(D)));        % D is a vector of standard deviations now

        %Update sigma to ensure convergence
        sigma = sigma / gamma;

%         plot_foil(xmean, wing)

        %Calculate the fitness of the mean
        foil = pts2ind(xmean, n_param.numEvalPts);
        fitness(iFit) = feval(task, n_param, foil);


        % Break, if fitness is good enough or condition exceeds 1e14, better termination methods are advisable
%         if arfitness(1) <= stopfitness
%             return;
%         end

    %     disp([num2str(counteval) ': ' num2str(arfitness(1))]);
        iFit = iFit +1;
        counteval = counteval+1;
    end % while, end generation loop

end


