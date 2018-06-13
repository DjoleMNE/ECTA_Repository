function output = shape_ES(init_sigma, nacafoil, numEvalPts)
             
sigma = init_sigma;
successful_mutations = 0;
p.nGenes = 32;
p.popSize = 1;
total_time = 0;
gamma = (20/17)^(1/p.nGenes);
time_period = 5 * gamma;

population = rand(p.popSize, p.nGenes) - 0.5;
[value, matrix] = shape_calc_fitness(population, nacafoil, numEvalPts, p);      

fitness = value;
foil = matrix;
new_population = population;
count = 1;

%% Generation Loop
while count < 20000
    
    for index = 1:p.nGenes    
        noise = 0.5 .* randn(p.popSize, 1);
        temp = population(index) + sigma * noise;
        while temp > 0.5 || temp < -0.5
            noise = 0.5 * randn(p.popSize, 1);
            temp = population(index) + sigma * noise;
        end
        new_population(index) = temp;
    end
    
    [value, matrix] = shape_calc_fitness(new_population, nacafoil, numEvalPts, p);      
    new_fitness = value;
    new_foil = matrix;
    count = count + 1; 
    
    if new_fitness >= fitness
       successful_mutations = successful_mutations + 1; 
       population = new_population;
       fitness = new_fitness
       foil = new_foil;
    end 
    
    if mod(total_time, time_period) == 0
                
        if (successful_mutations / time_period) < 1/5
            sigma = sigma / gamma;
        else
            sigma = sigma * gamma;
        end
        
        successful_mutations = 0;
    end
    total_time = total_time + 1;
end

%% Setting outputs
output.best = population;
output.best_foil = foil;
