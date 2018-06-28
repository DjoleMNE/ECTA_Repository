function output = leading_zeros_fitness(population)
[m n ] = size(population);
output = zeros(m,1);
for i = 1:m
    individual = population(i,:);
    count = 0;
    flag = true ;
    for j = 1: n
        if individual(1,j) == 0 && flag == true
            count = count + 1;
        else
            flag = false;
        end
    end
    output(i,1) = count ;
end
