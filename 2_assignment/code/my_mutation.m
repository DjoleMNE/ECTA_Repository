function children  = my_mutation(input_children, popSize, nGenes, mutProb)
%Mutation - Make random changes in the child population
% - Point mutation:
% Syntax:  children  = my_mutation(children, p);
%
% Inputs:
%    children   - [M X N] - Population of M individuals
%    mutProb              - Chance per gene of performing mutation
%
% Outputs:
%    children   - [M X N] - New population of M individuals
%

%------------- BEGIN CODE --------------
%Initialize children matrix and seed of random generator
children = input_children;

for child = length(children);
    child = children(1,:);
    for j = 1: length(child);
        if rand < mutProb
            previous = child(j);
            index = randi(length(child));
            child(j) = child(index);
            child(index) = previous;
            children(j,:)= child;
        end  
    end
end

%firstindex = randi([1,nGenes],1);
%secondindex = randi([1,nGenes],1);
%children = chromosome;
% 
% new_chromosome(:,firstindex) = chromosome(:,secondindex);
% new_chromosome(:,secondindex) = chromosome(:,firstindex);
%children(firstindex:secondindex) = chromosome(fliplr(firstindex:secondindex));

end

%------------- END OF CODE --------------