function fitness = calculate_fitness(n_param, population,p)
for iPop = 1:p.popSize
    [foil, ~] = pts2ind(population(iPop,:)', n_param.numEvalPts);

    [~,errorTop] =    dsearchn(n_param.nacafoil(:,1:end/2)'    , foil(:,1:end/2)');
    [~,errorBottom] = dsearchn(n_param.nacafoil(:,1+end/2:end)', foil(:,1+end/2:end)');

% Total fitness (mean squared error)
    fitness(iPop) = mean([errorTop.^2; errorBottom.^2]);
end

