%PTS2IND Converts a vector of control pts to an individual with a genotype
%of control points and a phenotype of interpolated of cartesian points


function [ foil, nurbs ] = pts2ind( ctlPts, varargin )
% The number of control points is ctlPts+2 (with ctlPts an even number) as 
% these define the leading and trailing edge with x value == 0 to ensure a
% chord length of one. The other control points will be fixed to a grid of 
% x values from (and incl.) 0 to (and incl.) 1.
%
% All gene values are assumed to be between 0 and 1
%
%%
numEvalPts = 128;
if length(varargin) > 0
    numEvalPts = varargin{1};
end

totalPts = length(ctlPts)+2;
% Y values defined as distance away from center line 
yTop = ctlPts(1:end/2)';
yBot = ctlPts(1+end/2:end)';
% X coordinates are defined as a position on the chord from 0 to 1
x = [0 linspace(0,1,length(ctlPts)/2) 1 linspace(1,0,length(ctlPts)/2)];
% Add y coordinates of leading and trailing edge as average between
% neighbour points
leadY = (yTop(1)+yBot(end))/2;
trailY = (yTop(end)+yBot(1))/2;

y = [leadY yTop trailY yBot];

%Close control pts
coefs = [x;y];
coefs = [coefs coefs(:,1)];

% Create Knot Vector
curveDegree = 3;
knotLength = length(coefs) + curveDegree + 1;  
knotVector = [zeros(1,curveDegree) linspace(0,1,(knotLength-curveDegree*2)) ones(1,curveDegree)];

nurbs = nrbmak(coefs,knotVector);
foil = nrbeval(nurbs,linspace(0.0,1,numEvalPts));
foil = foil([1 2],:);

% Plot resulting shape
% plot(foil(1,:),foil(2,:));
% hold on;plot(nurbs.coefs(1,:), nurbs.coefs(2,:),'ko--');hold off;
% axis([-0.1 1.1 -1.2 1.2])


end

