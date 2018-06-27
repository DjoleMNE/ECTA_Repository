function  [population,F] = non_dominated_sort(population,p)

F{1}=[];
[m n] = size(population);

for i=1:m
    population(i).DominatedSet = [];
    population(i).DominatedCount = 0;
    for j = 1:m
        if j==i
            continue;
        end
        
        if dominates(population(i),population(j))
            population(i).DominatedSet(end+1) = j;
        elseif dominates(population(j),population(i))
            population(i).DominatedCount = population(i).DominatedCount + 1;
        end
    end
    
    if population(i).DominatedCount == 0
        population(i).rank =1;
        F{1}(end+1) = i ;
    end
end
front = 1;
while true
    Q = [];
    for i = 1:numel(F{front})
        p = population(F{front}(i));
        for j = 1: numel(p.DominatedSet)
            q = population(p.DominatedSet(j));
            q.DominatedCount = q.DominatedCount -1 ;
            if q.DominatedCount == 0
                q.rank = front +1;
                Q(end+1) = p.DominatedSet(j);
            end
            population(p.DominatedSet(j)) = q;
        end
    end
    if isempty(Q)
        break;
    end
    F{front + 1} = Q;
    front = front +1;
end
end