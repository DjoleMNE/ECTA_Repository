function children = nsga_crossover(pop, parentIds, p)


%------------- BEGIN CODE --------------
%Initialize children matrix by assigning only first individual of all pairs

for i=1:p.popSize
    parentA = pop(parentIds(i,1)).value;
    parentB = pop(parentIds(i,2)).value;
    length = size(parentA);
    index = randi(length(:,2),1);
    if p.crossProb > rand(1,1)
        children(i,:) = [parentA(1:index) parentB(index+1:end)];
    else
        children(i,:) = parentA(1:end);
    end
end  
%------------- END OF CODE -------------