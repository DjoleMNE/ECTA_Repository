clc;
clear;
close all;
p.nGenes = 20;
p.maxGen    = 200;
p.popSize   = 100;
p.selection_pressure = 2;
p.crossProb = 0.9gif('nsga2.gif');;
p.mutProb   = 0.1;
p.elitePerc = 0.1;
output = p;

%    Initialize population

for i= 1: p.popSize
    NInd(i).DominatedSet = 0;
    NInd(i).DominatedCount = [];
    NInd(i).rank = 0;
    NInd(i).value = randi([0 1],[1,p.nGenes]) ;
    NInd(i).fitness  = [leading_zeros_fitness(NInd(i).value),trailing_ones_fitness(NInd(i).value)];
    NInd(i).Crowding_distance = 0;
    populationMatrix(i) = NInd(i);
end

populationMatrix = populationMatrix';

for n = 1:p.maxGen
    [populationMatrix, F] = non_dominated_sort(populationMatrix);
    populationMatrix = Crowding_distance(populationMatrix,F);
    
    parentIds = nsga_selection([populationMatrix.Crowding_distance], p);
    children  = nsga_crossover(populationMatrix, parentIds, p);
    children  = nsga_mutation(children, p);
    
    for i= 1: p.popSize
        NInd(i).DominatedSet = 0;
        NInd(i).DominatedCount = [];
        NInd(i).rank = 0;
        NInd(i).value = children(i,:);
        NInd(i).fitness  = [leading_zeros_fitness(NInd(i).value) ,trailing_ones_fitness(NInd(i).value)];
        NInd(i).Crowding_distance = 0;
        pop_2(i,:) = NInd(i);
    end
    populationMatrix = [populationMatrix;pop_2];
    [populationMatrix, F] = non_dominated_sort(populationMatrix);
    populationMatrix = Crowding_distance(populationMatrix,F);
    pop_matrix = sort_pop(populationMatrix);
    total_idx = pop_matrix.sorted_pop_idx;
    populationMatrix= pop_matrix.sorted_pop;
    
    next_index = total_idx(1:100);
    failed_index = total_idx(101:200);
    
    populationMatrix.fitness
    size(reshape([populationMatrix.fitness],2,[])')
    hold on;
    displayFronts([populationMatrix.rank]', reshape([populationMatrix.fitness],2,[])', vertcat(populationMatrix.value), next_index, failed_index,p);
    drawnow;
    hold off;
    populationMatrix = populationMatrix(1:p.popSize);
end

