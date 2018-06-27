function output = sort_pop(population)
    dist_sort = [population.Crowding_distance];
    [dist_sort, sort_idx] = sort(dist_sort, 'descend');
    population = population(sort_idx);

    rank_pop = [population.rank];
    [rank_pop, sort_idx] = sort(rank_pop);
    population = population(sort_idx);
    
    
    output.sorted_pop = population;
    output.sorted_pop_idx = sort_idx;
end