function sorted_pop = sort_pop(populationMatrix)
    dist_sort = [populationMatrix.Crowding_distance];
    [~, sort_idx] = sort(dist_sort, 'descend');
    populationMatrix = populationMatrix(sort_idx);

    rank_pop = [populationMatrix.rank];
    [rank_pop, sort_idx] = sort(rank_pop);
    populationMatrix = populationMatrix(sort_idx);
    
    
    sorted_pop.populated = populationMatrix;
    sorted_pop.index = sort_idx;
end