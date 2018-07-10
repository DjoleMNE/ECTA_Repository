function [result, foils] = shape_calc_fitness(population, nacafoil, numEvalPts, p)
%% Look up distance for one individual
% distMat = squareform(pdist(coordinates')); % Precalculate Distance Matrix
result = NaN([p.popSize 1]);
foils = NaN([2 numEvalPts p.popSize]);

%% Compute mean square error - MSE
for index = 1:p.popSize
    % Extract spline representation of a foil 
    % (with the same number of evaluation  points as the NACA profile)
    individual = population(index, :)';

    [foil, ~] = pts2ind(individual, numEvalPts);
    foils(:, :, index) = foil;
    
    % Calculate pairwise error
    [~,errorTop] = dsearchn(nacafoil(:, 1:end/2)', foil(:, 1:end/2)');
    [~,errorBottom] = dsearchn(nacafoil(:, 1+end/2:end)', foil(:, 1+end/2:end)');

    % Total fitness (mean squared error)
    fitness = mean([errorTop.^2; errorBottom.^2]);
    result(index, 1) = 1 / (fitness + 0.01) ; 
end 
