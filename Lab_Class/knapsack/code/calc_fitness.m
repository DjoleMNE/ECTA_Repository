function result = calc_fitness(population, population_size, value)
    result = NaN([population_size 1]);

    for index = 1:population_size
        result(index) = sum( value( logical(population( index, :))));
    end 
end