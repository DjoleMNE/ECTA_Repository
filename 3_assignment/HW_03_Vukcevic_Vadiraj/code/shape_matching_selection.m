function parentIds = shape_matching_selection(fitness, p)

%Initialize 100x2 matrix of parent indices
parentIds = randi(p.popSize, [p.popSize 2]);

random_pick = randi(p.popSize, [p.selection_pressure p.popSize]); % Make tournament groups %200 as it needs 2 parents for crossover
%iWinner = randi(tGroups, [p.selection_pressure p.popSize*2]);         % Get Winner
for i=1:length(random_pick);
    parentIds(i) = random_pick(i); 
end 
%Get 200 winners and make 100 pairs of them - Tournament selection
% for i=1:p.popSize*2
%     for k=1:2         
%         %Get random indeces of individuals.
%         %Syntax: range, [size of matrix]
%         randomPair = randi(p.popSize,[p.selection_pressure,1]);
%         
%         %choose index of max between two rows
%         [~, winner_index]= min(fitness(randomPair));
%         
%         %Fill out parentIds matrix...syntax for matrix(i):
%         %goes over whole first row, than over  whole second row, and so on.
%         %Fill 100x2 matrix -> 100 pairs of 200 parents.
%         parentIds(i) = randomPair(winner_index);
%     end
% end





%% For ES
%Get 200 winners and make 100 pairs of them 
for i=1:p.popSize*2
    for k=1:2         
        %Get random indeces of individuals.
        %Syntax: range, [size of matrix]
        randomPair = randi(p.popSize,[p.selection_pressure,1]);
        
        %choose index of max between two rows
        [~, winner_index]= min(fitness(randomPair));
        
        %Fill out parentIds matrix...syntax for matrix(i):
        %goes over whole first row, than over  whole second row, and so on.
        %Fill 100x2 matrix -> 100 pairs of 200 parents.
        parentIds(i) = randomPair(winner_index);
    end
end
