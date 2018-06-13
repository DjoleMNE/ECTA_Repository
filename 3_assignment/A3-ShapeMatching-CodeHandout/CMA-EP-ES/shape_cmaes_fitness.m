function fitness = shape_cmaes_fitness(individual,nacafoil,numEvalPts)
[foil, nurbs] = pts2ind(individual,numEvalPts);
% Calculate pairwise error
half = round(nacafoil/2);
[~,errorTop] =    dsearchn(nacafoil(:,1:end/2)'    ,foil(:,1:end/2)');
[~,errorBottom] = dsearchn(nacafoil(:,1+end/2:end)',foil(:,1+end/2:end)');
% Total fitness (mean squared error)
current_fitness = mean([errorTop.^2; errorBottom.^2]);
error = current_fitness;
fitness = 1.0 / current_fitness ;
end