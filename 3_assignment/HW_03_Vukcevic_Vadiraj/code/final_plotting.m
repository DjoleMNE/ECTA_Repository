%% Calculating the best individuals over 20 runs for four different algorithms
 clear all; 
 clc; 
% tic
for i=1:3
    % Running GA
    wing_type = 3;
    disp(['N_Param: ' num2str(wing_type)])
    fitness = [];
    parfor iExp = 1:5
        n_param = shape_matching_ga(wing_type);
        p = shape_matching_ga(wing_type,'meansquaremulti', n_param);
        output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
        fitness(iExp,:) = output.fitMax;
    end
    GAFitness = fitness;
    disp('GA done')
   
    
    
    % Running ES
    fitness = [];
    parfor iExp = 1:5
        fitness(iExp,:) = ES(wing_type);
    end
    ESFit = fitness;
    disp('ES done')
    fitness = [];
%     
    % Running CMA-ES without evolution path
    parfor iExp = 1:5
        fitness(iExp,:) = CMA_ES(wing_type);
    end
    CMAESFitness_s = fitness;  
    disp('CMA-ES without EP done')
    
    fitness = [];
    % Running CMA-ES with evolution path
    parfor iExp = 1:5
        fitness(iExp,:) = CMA_ES_EP(wing_type);
    end
    CMAESFitness = fitness;   
    disp('CMA-ES with EP done')
    
    
    save(['Final_Comparison_3'], 'GAFitness', 'ESFit', 'CMAESFitness_s', 'CMAESFitness')
end
% 
%% Plotting 
%Shape 1 Data

load('Final_Comparison1.mat')
GA_wing1 = GAFitness;
ES_wing1 = ESFit;
CMA_ES_Noep_wing1 = CMAESFitness_s;
CMA_ES_wing1 = CMAESFitness;

%Shape 2 Data

load('Final_Comparison_2.mat')
GA_wing2= GAFitness;
ES_wing2 = ESFit;
CMA_ES_Noep_wing2 = CMAESFitness_s;
CMA_ES_wing2 = CMAESFitness;

%Shape 3 Data

load('Final_Comparison_3.mat')
GA_wing3 = GAFitness;
ES_wing3 = ESFit;
CMA_ES_Noep_wing3 = CMAESFitness_s;
CMA_ES_wing3 = CMAESFitness;

%Plot 


plot(median([GA_wing1;GA_wing2;GA_wing3]),'LineWidth',3)
hold on
plot(median([ES_wing1;ES_wing2;ES_wing3]),'LineWidth',3)
plot(median([CMA_ES_Noep_wing1;CMA_ES_Noep_wing2;CMA_ES_Noep_wing3]),'LineWidth',3)
plot(median([CMA_ES_wing1;CMA_ES_wing2;CMA_ES_wing3]),'LineWidth',3)

legend('GA ','ES','CMA-ES No EP', 'CMA-ES with EP Path','Location','NorthEast');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16,'YScale','log');
title('Final Comparison of all plots')
grid

%% GA vs ES
%Real value
parfor iExp = 1:5
    n_param = shape_matching_ga(wing_type);
    p = shape_matching_ga(wing_type,'meansquaremulti', n_param);
    output = shape_matching_ga(wing_type,'meansquaremulti', n_param, p);
    fitness(iExp,:) = output.fitMax;
    %fit_median(iExp,:) = output.fitMed;
    [lowest, ilowest] = min(output.fitMax);
    best = output.best(:,ilowest)';
    best_ind{iExp} = {best, lowest};
end
disp('GA real values')
toc;

%Extracting the values from the best_ind cells
for i=1:5
    indbest(i) = best_ind{i}{2};
end

%Getting the best individual
[~, iVal] = min(indbest);
smallest_Real = best_ind{iVal}{1};
GA_Real_Fit = median(fitness);

fitness = [];
parfor iExp = 1:5
   [fitness(iExp,:), best_individuals(:,iExp)] = ES(wing_type);
end

ESFitness_med = median(fitness);
disp('ES done')

plot([GA_Real_Fit; ESFitness_med]','LineWidth',3);
legend('GA-medfit','ES-medfit','Location','NorthEast');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',16,'YScale','log');
title('Comparing GA vs ES')
grid

plot_foil(smallest_Real', n_param)
best_individual_ES = mean(best_individuals,2);
plot_foil(best_individual_ES, n_param);


%% ES vs CMA ES No evolutionary paths
fitness = [];
parfor iExp = 1:5
   [fitness(iExp,:), best_individuals(:,iExp)] = CMA_ES(wing_type);
end

CMA_ES_NFitness_med = median(fitness);
disp('CMA-ES done')

plot([ESFitness_med; CMA_ES_NFitness_med]','LineWidth',3);
legend('ES','CMA-ES without path','Location','NorthEast');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',13,'YScale','log');
title('Comparison of ES vs CMA-ES')
grid

best_individual_CMA_ES_N = mean(best_individuals,2);
plot_foil(best_individual_CMA_ES_N, n_param);

%% CMA ES No evolutionary paths vs CMA-ES with evolution paths
fitness = [];
parfor iExp = 1:5
   [fitness(iExp,:), best_individuals(:,iExp)] = CMA_ES_EP(wing_type);
end

CMA_ES_Fitness_med = median(fitness);
disp('CMA-ES done')

plot([ESFitness_med; CMA_ES_Fitness_med]','LineWidth',3);
legend('CMA-ES no EP','CMA-ES with EP','Location','NorthEast');
xlabel('Generations'); ylabel('Fitness'); set(gca,'FontSize',13,'YScale','log');
title('CMA-ES-EP vs CMA-ES-NOEP')
grid

% best_individual_CMA_ES = mean(best_individuals,2);
% plot_foil(best_individual_CMA_ES, wing);

