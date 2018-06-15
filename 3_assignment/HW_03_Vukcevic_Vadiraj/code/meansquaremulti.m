function fitness = meansquaremulti(n_param, pop)
    fitness = zeros(length(pop),1);
    for iPop = 1:length(pop)
        foil = n_param.foil{iPop};
        fitness(iPop) = mean_square(n_param, foil);
    end
end