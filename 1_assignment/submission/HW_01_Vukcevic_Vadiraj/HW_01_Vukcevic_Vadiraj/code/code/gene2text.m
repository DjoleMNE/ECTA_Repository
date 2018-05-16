function chars = gene2text(genome)
%gene2text - Converts genome of back to text
%
% Syntax:  chars = gene2text(genome)
%
% Inputs:
%    genomes - [M X N] - M genomes of length N, ints between 0 and 26
%
% Outputs:
%    chars   - [M X N] - Vector of characters, from a to z with spaces
%
% Example: 
%    quote = 'to be or not to be';
%    targetGenes  = text2gene(quote);
%    targetString = gene2text(targetGenes);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: text2gene,  hamletQuote, hamletSoliloquy

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------

genome = genome + 96;
genome(genome==96) = 32; % Space
genome(genome==123)= 10; % LineBreak
chars = char(genome);

end