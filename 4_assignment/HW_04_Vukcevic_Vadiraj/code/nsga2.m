clc;
clear;
close all;
p.nGenes = 20;
p.maxGen    = 1000;
p.popSize   = 10;
p.selection_pressure = 2;
p.crossProb = 0.8;
p.mutProb   = 0.2;
%p.elitePerc = 0.1;
output = p;

%Initialize population
tic;
for i= 1: p.popSize
    individual(i).value = randi([0 1],[1,p.nGenes]) ;
    individual(i).np = 0;
    individual(i).sp = [];
    individual(i).rank = 0;
    individual(i).fitness  = [leading_zeros_fitness(individual(i).value),trailing_ones_fitness(individual(i).value)];
    individual(i).Crowding_distance = 0;
    populationMatrix(i) = individual(i);
end

populationMatrix = populationMatrix';

for n = 1:p.maxGen
    
    [populationMatrix, F] = non_dominated_sort(populationMatrix);
    populationMatrix = Crowding_distance(populationMatrix,F);
    
  %  parentIds = nsga_selection([populationMatrix.Crowding_distance], p);
    parentIds = nsga_selection(populationMatrix, p);
    children  = nsga_crossover(populationMatrix, parentIds, p);
    children  = nsga_mutation(children, p);
    
    for i= 1: p.popSize
        individual(i).value = children(i,:);
        individual(i).np = 0;
        individual(i).sp = [];
        individual(i).rank = 0;
        individual(i).fitness  = [leading_zeros_fitness(individual(i).value) ,trailing_ones_fitness(individual(i).value)];
        individual(i).Crowding_distance = 0;
        pop_2(i,:) = individual(i);
    end
    
    populationMatrix = [populationMatrix;pop_2];
    [populationMatrix, F] = non_dominated_sort(populationMatrix);
    populationMatrix = Crowding_distance(populationMatrix,F);
    sorted_out = sort_pop(populationMatrix);
    populationMatrix = sorted_out.populated;
    pop_idx = sorted_out.index; 
    
    next_gen_index = pop_idx(1:p.popSize);
    %failed_index = populationMatrix(11:20);
%     pop_idx(1:p.popSize);
    failed_index = pop_idx(p.popSize+1:p.popSize*2);
       
    
    hold on;
    displayFronts([populationMatrix.rank]', reshape([populationMatrix.fitness],2,[])', vertcat(populationMatrix.value),next_gen_index,failed_index);
    drawnow;
    hold off;
    
    if n == 1
         gif('nsga_300.gif','frame', gcf,'DelayTime', 0.2);
    else 
         gif;
    end
    populationMatrix = populationMatrix(1:p.popSize);
end
toc;