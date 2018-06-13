function update_term = rank_mu_update(individualsMat, meanIndividual, weights,nGenes,cmu,sigma,mu)

    C_mu = zeros(nGenes, nGenes);
    for i= 1:mu
        C_mu = C_mu + weights(i) * (individualsMat(:,i) - meanIndividual) *...
                            (individualsMat(:,i) - meanIndividual)';
    end
    
    update_term = cmu * (1/sigma^2) * C_mu;