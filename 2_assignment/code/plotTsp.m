function h  = plotTsp(genes, coords, img)
%plotTsp - Plots TSP route over an actual map
%
% Syntax:  figureHandle  = plotTsp(genes)
%
% Inputs:
%    genes      - [1 X M] - 5 city IDs
%    parentIds  - [2 X M] - (x,y) coordinates of cities
%    img        -         - string to image, or image matrix itself
%
% Outputs:
%    h          - [M X N] - Handle to plotted line
%

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Apr 2018; Last revision: 25-Apr-2018

%------------- Input Parsing ------------
if      nargin < 3;   img = imread('germany-cities-map.jpg'); 
elseif ischar(img); img = imread(img); 
end
%------------- BEGIN CODE --------------
% Plot background image
imagesc(img); hold on; 

% Plot line (just fit by trial and error, not exact)
h = plot(coords(1,[genes genes(1)])*73-380,...
        -coords(2,[genes genes(1)])*120+6665,...
        '-o', 'LineWidth', 2);
axis equal; axis tight;
xticks('');yticks('');


%------------- END OF CODE --------------