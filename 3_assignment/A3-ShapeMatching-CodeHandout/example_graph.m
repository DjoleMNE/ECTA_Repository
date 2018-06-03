%% ASSESSMENT 2: GRAPH COLORING PROBLEM
%  Color the nodes of an undirected buckyball graph. The objective is to have 
%  no neighboring nodes with the same color. This problem is known to be 
%  NP-complete, so we will use a genetic algorithm to solve it.
% 
%  Adjust your TSP implementation to produce integer arrays (1D matrices)
%  that assign a color id to every node. The 'graphcolorsolution' variable
%  holds the example graph. Please use the small example graph to debug your 
%  code. This makes it much easier to notice problems with your operators.
%
%  You have to adjust your operators. For example, the GA needs to be able 
%  to mutate the color of a single node. Do not blindly use your TSP 
%  operators but make a small sketch of your plan before you start coding.
%
%
%  After that, please execute your algorithm on the buckyball graph. 
%  Make sure a single run does not take too much time! Adjust your
%  population size and number of generations accordingly.
%  Repeat your experiment at least 10 times, describe your results 
%  (concise visualization and statistical measures).
%
%  Snip out the necessary code fragments from this script.

clear;clc;

%% 1) Get k colors from the 'jet' colormap. 
%  We will try to color our graph with 4 colors in this assignment
kcolors = 4; colors = jet(kcolors);

%% 2) Setup the graphs
% 2a) Setup a small graph for testing your code
adjacency = [0,1,0,1,0;
             0,0,1,0,0;
             0,0,0,1,1;
             0,0,0,0,1;
             0,0,0,0,0];

% 2b) After your code works, create a graph from a buckyball adjacency matrix
% Uncomment the following line

% adjacency = bucky;

% 3) Create graph. As an adjacency matrix for an undirected graph is symmetrical, we can ignore the lower triangle.
g = graph(adjacency,'upper');

%% This is an example coloring solution (with colors 1,..,k)
graphcolorsolution = randi(kcolors,size(adjacency,1),1);
disp('This is an example solution to the graph coloring problem: ');
disp(mat2str(graphcolorsolution));

%% Get penalty by checking colors for all neighbours of all nodes
% The penalty is increased for every edge that connects same colored nodes.
penalty = 0;
for node=1:size(adjacency,1)
    for neigh=find(adjacency(node,:)==1)
        if graphcolorsolution(node) == graphcolorsolution(neigh)
            penalty = penalty + 1;
        end
    end
end
disp(['Penalty = ' int2str(penalty)]);


%% Visualization
fig = figure(1);
h = plot(g,'MarkerSize',12,'LineWidth',3);
for i=1:kcolors
    highlight(h,find(graphcolorsolution==i),'NodeColor',colors(i,:));
end
title('Colored example graph');
ax = gca;
ax.XTick = []; ax.YTick = [];
save_figure(fig, 'graph_example', 18); 