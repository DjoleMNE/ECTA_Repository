function eliteIds = tsp_elitism(fitness, p)

%------------- BEGIN CODE --------------
elite_individuals = p.popSize * p.elitePerc;

[sorted_values,sorted_ids]= sort(fitness,'descend');  

eliteIds = sorted_ids(1:ceil(elite_individuals));              
%------------- END OF CODE --------------