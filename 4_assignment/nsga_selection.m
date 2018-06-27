function parentIds = nsga_selection(fitness, p)



random_pair = zeros(p.popSize,2);

for i=1:p.popSize
    Pa = randi(p.popSize,[1 p.selection_pressure]);
    if fitness(Pa(1)) >  fitness(Pa(2))
        random_pair(i,1) = Pa(1);
    else
        random_pair(i,1) = Pa(2);
    end
    
    Pb = randi(p.popSize,[1 p.selection_pressure]);
    if fitness(Pb(1)) >  fitness(Pb(2))
        random_pair(i,2) = Pb(1);
    else
        random_pair(i,2) = Pb(2);
    end
end
parentIds = random_pair;


%------------- END OF CODE --------------