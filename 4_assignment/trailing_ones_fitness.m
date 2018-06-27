function output = trailing_ones_fitness(population)

[m n ] = size(population);
output = zeros(m,1);
for i = 1:m
    ind = population(i,:);
    ind = fliplr(ind);
    no_of_ones = 0;
    flg = true ;
    for j = 1: n
        if ind(1,j) == 1 && flg == true
            no_of_ones = no_of_ones + 1;
        else
            flg = false;
        end
    end
    output(i,1) = no_of_ones ;
end


