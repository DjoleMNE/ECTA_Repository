function populationMatrix= Crowding_distance(populationMatrix,F)

nF = numel(F);
no_of_fitness = 2;
for f = 1:nF
    for i = 1:numel(F{f})
        populationMatrix(F{f}(i)).Crowding_distance = 0.0;
    end
    
    fitness_array = reshape([populationMatrix(F{f}).fitness],2,[]);
    D =zeros(size(fitness_array));
    for m = 1:no_of_fitness
        [sorted idx] = sort(fitness_array(m,:));
        first_idx = idx(1);
        last_idx = idx(end);
        D(m,first_idx) = inf;
        D(m,last_idx) = inf;
        max_fitness = max(sorted);
        min_fitness = min(sorted);
        
       % population(F{f}(last_idx)).Crowding_distance = inf;
        for k = 2:numel(idx)-1
            D(m,k) = D(m,k)+ (sorted(k+1) - sorted(k-1)) / (max(sorted) - min(sorted));
        end
    end
    D(isnan(D)) = 0;
    D = sum(D,1);
    for i = 1:numel(F{f})
        populationMatrix(F{f}(i)).Crowding_distance = D(i);
    end
end
end



