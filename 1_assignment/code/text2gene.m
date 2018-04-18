function genes = text2gene(chars)
%text2gene - Converts text string to genome of 27 possible values
%
% Syntax:  genes = text2gene(chars)
%
% Inputs:
%    chars - [1 X N] - Vector of characters for conversion
%
% Outputs:
%    output1 - [1 X N] - Vector of ints
%
% Example: 
%    quote = 'to be or not to be';
%    targetGenes = text2gene(quote);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: gene2text,  hamletQuote, hamletSoliloquy

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 20-Feb-2018

%------------- BEGIN CODE --------------

numbers   = uint8(chars); % Convert to ascii
lineBreak = numbers==10;  % Store linebreak
genes     = numbers-96;   % Convert to genes
genes(lineBreak) = 27;    % Assign linebreak to gene 27

%------------- END OF CODE --------------
end