function parentIds = nsga_selection(populationMatrix, p)

% random_pair = zeros(p.popSize,2);
% 
% for i=1:p.popSize
%     Pa = randi(p.popSize,[1 p.selection_pressure]);
%     if fitness(Pa(1)) >  fitness(Pa(2))
%         random_pair(i,1) = Pa(1);
%     else
%         random_pair(i,1) = Pa(2);
%     end
%     
%     Pb = randi(p.popSize,[1 p.selection_pressure]);
%     if fitness(Pb(1)) >  fitness(Pb(2))
%         random_pair(i,2) = Pb(1);
%     else
%         random_pair(i,2) = Pb(2);
%     end
% end
% parentIds = random_pair;

population_pair = ones(p.popSize,2);
for i=1:p.popSize
    a = randi([1 p.popSize],[1 p.selection_pressure]);
    if populationMatrix(a(1)).rank <  populationMatrix(a(2)).rank
        population_pair(i,1) = a(1);
    elseif populationMatrix(a(1)).rank ==  populationMatrix(a(2)).rank
        if populationMatrix(a(1)).Crowding_distance > populationMatrix(a(2)).Crowding_distance
            population_pair(i,1) = a(1);
        else
            population_pair(i,1) = a(2);
        end
    else
        population_pair(i,1) = a(2);
    end

    b = randi([1 p.popSize],[1 p.selection_pressure]);
    if populationMatrix(b(1)).rank <  populationMatrix(b(2)).rank
        population_pair(i,2) = b(1);
    elseif populationMatrix(b(1)).rank ==  populationMatrix(b(2)).rank
        if populationMatrix(b(1)).Crowding_distance > populationMatrix(b(2)).Crowding_distance
            population_pair(i,1) = b(1);
        else
            population_pair(i,1) = b(2);
        end
    else
        population_pair(i,2) = b(2);
    end
end
parentIds = population_pair;
end
%------------- END OF CODE --------------