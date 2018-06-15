function fitness = fitness_meansquare(n_param, foil)
    [~,errorTop] =    dsearchn(n_param.nacafoil(:,1:end/2)'    ,foil(:,1:end/2)');
    [~,errorBottom] = dsearchn(n_param.nacafoil(:,1+end/2:end)',foil(:,1+end/2:end)');

    % Total fitness (mean squared error)
    fitness = mean([errorTop.^2; errorBottom.^2]);
end