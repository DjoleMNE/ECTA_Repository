function  [populationMatrix,F] = non_dominated_sort(populationMatrix)

F{1}=[];
[m n] = size(populationMatrix);

for i=1:m
    populationMatrix(i).sp = [];
    populationMatrix(i).np = 0;
    for j = 1:m
        if j==i
            continue;
        end
        
        if dominates(populationMatrix(i),populationMatrix(j))
            populationMatrix(i).sp(end+1) = j;
        elseif dominates(populationMatrix(j),populationMatrix(i))
            populationMatrix(i).np = populationMatrix(i).np + 1;
        end
    end
    
    if populationMatrix(i).np == 0
        populationMatrix(i).rank =1;
        F{1}(end+1) = i ;
    end
end
front = 1;
while true
    Q = [];
    for i = 1:numel(F{front})
        p = populationMatrix(F{front}(i));
        for j = 1: numel(p.sp)
            q = populationMatrix(p.sp(j));
            q.np = q.np -1 ;
            if q.np == 0
                q.rank = front +1;
                Q(end+1) = p.sp(j);
            end
            populationMatrix(p.sp(j)) = q;
        end
    end
    if isempty(Q)
        break;
    end
    F{front + 1} = Q;
    front = front +1;
end
end