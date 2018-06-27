function output =dominates(p,q)

p_fit = [leading_zeros_fitness(p.value), trailing_ones_fitness(p.value)];
q_fit = [leading_zeros_fitness(q.value), trailing_ones_fitness(q.value)];

   output = all(p_fit >= q_fit) && any(p_fit > q_fit);
end

