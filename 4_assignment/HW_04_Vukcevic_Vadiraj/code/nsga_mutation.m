function children  = nsga_mutation(children, p)

for i = 1:p.popSize
    do_mut = (rand(1,p.nGenes) < p.mutProb);
    for j = 1:length(do_mut)
        if do_mut(1,j)==1
            children(i,j) = randi([0 1],1);
        end
    end
end
end
%------------- END OF CODE --------------