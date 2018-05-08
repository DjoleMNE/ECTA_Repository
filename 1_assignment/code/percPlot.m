function [hLine, hFill] = percPlot(x,y,varargin)
%percPlot - Plots a dataset's median, 25th, and 75th percentile
%
% Syntax:  fitness = hamletQuote(genomes)
%
% Inputs:
%    x      - [1 X N] - xScale (e.g. generations, iterations, evaluations)
%    y      - [M X N] - Matrix of performance values at each e.g. iteration
%  varargin - {     } - format {color,edge,add,transparency} (see jbfill)
%
% Outputs:
%    hLine  - _handle - Handle to colored median line
%    hFill  - _handle - Handle to fill patch
%
% Example: 
%     x=1:20;      % Horizontal vector
%     y=rand(5,20);% Vector of 5 experiments run for 20 iterations
%     percPlot(x,y); % Default formatting
%     y2=rand(5,20);% Vector of 5 experiments run for 20 iterations
%     percPlot(x,y,'b','r',0,0.5); % Blue fill, Red Edge, new plot, with 0.5 opacity)
%
% Other m-files required: prctile (Stats & ML toolbox), jbfill 
%
% See also: jbfill, boundedline

% Author: Adam Gaier
% Bonn-Rhein-Sieg University of Applied Sciences (BRSU)
% email: adam.gaier@h-brs.de
% Feb 2018; Last revision: 21-Feb-2018

%------------- BEGIN CODE --------------

% Get stats from data
medY = median(y);
uprY = prctile(y,75);
lwrY = prctile(y,25);

if ~isempty(varargin) 
    hFill = jbfill(x,uprY,lwrY,varargin{:});hold on;
    hLine = plot(x, medY,'Color',varargin{1},'LineWidth',2); 
else               
    hFill = jbfill(x,uprY,lwrY); hold on;
    hLine = plot(x, medY,'Color','k','LineWidth',1); 
end
plot(x, medY,'k--','LineWidth',1); % Dotted line to make median more clear 
hold off

%------------- END OF CODE --------------