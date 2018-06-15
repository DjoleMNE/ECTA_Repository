% plotting

wing_type = 1;
n_param = shape_matching_ga(wing_type);
p = shape_matching_ga(wing_type,'meansquaremulti', n_param);
output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
disp("Foil calculated")
toc
%% Plotting fitness
plot([output.fitMax; output.fitMed]','LineWidth',3);
legend('Min Fitness','Median Fitness','Location','NorthWest');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16);
title('Performance of GeneticAlgorithm')

%% Plot

fitness = [];
parfor iExp = 1:number_of_iteration
   output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
   fitness(iExp,:) = output.fitMax;
   fitness(iExp,:) = output.fitMax';
end
GAResult = fitness;

fitness = zeros(number_of_iteration,number_of_generation);
parfor iExp = 1:number_of_iteration
    if number_of_iteration <= 20
        foil_id = naco(1,:);
    elseif (number_of_iteration >20) && (number_of_iteration <=40)
        foil_id = naco(2,:);
    else
        foil_id = naco(3,:); 
    end
    output = es(number_of_generation,false,foil_id);
    fitness(iExp,:) = output.fitMax';
end
ESResult = fitness;


fitness = zeros(number_of_iteration,number_of_generation_cms);
parfor iExp = 1:number_of_iteration
    if number_of_iteration <=20
        foil_id = naco(1,:);
    elseif (number_of_iteration >20) && (number_of_iteration <=40)
        foil_id = naco(2,:);
    else
        foil_id = naco(3,:);  
    end
    output = cma_without_path(number_of_generation_cms,false,foil_id);
    fitness(iExp,:) = output.fitMax';
end
CMA_without_Result = fitness;


fitness = zeros(number_of_iteration,number_of_generation_cms);
parfor iExp = 1:number_of_iteration
    if number_of_iteration <= 20
        foil_id = naco(1,:);
    elseif (number_of_iteration >20) && (number_of_iteration <=40)
        foil_id = naco(2,:);
    else
        foil_id = naco(3,:);
    end
    output = cma(number_of_generation_cms,false,foil_id);
    fitness(iExp,:) = output.fitMax';
end
CMAResult = fitness;

shape_max = max(GAResult);
shape_median = median(GAResult);
shape_max_bit = max(GAResult_bit);
shape_median_bit = median(GAResult_bit);
es_max = max(ESResult);
es_median = median(ESResult);
cma_without_max = max(CMA_without_Result);
cma_without_median = median(CMA_without_Result);
cma_max = max(CMAResult);
cma_median = median(CMAResult);


genrn = 1:number_of_generation;
genrn_cms = 1:number_of_generation_cms;

plot([100:100:20000],shape_median,[100:100:20000],shape_median_bit,[100:100:20000],es_median,[10:10:20000],cma_without_median,[10:10:20000],cma_median,'LineWidth',3);


legend('GA real median','GA bitstring median','ES - 1/5 - Median','CMA-without - Median','CMA - Median','Location','southeast')

xlabel("Evaluations")
ylabel("Fitness")
set(gca,'YScale','log')
title('Shape matching -  Comparision');