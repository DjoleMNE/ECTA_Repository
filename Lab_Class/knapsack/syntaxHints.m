%% MATLAB SYNTAX TIPS
% There are many ways to read data into files here are a few:
%% File input as a matrix
items = importdata('items.csv')
%%
items.data
%%
items.textdata
%%
weight = items.data(:,1)
%%

%% File input as a table (a mixed-type) matrix:
items = readtable('items.csv')

%% 
% Can be accessed like a normal matrix, but returns a table type
items([1 2 4],1)
%%
items([1:5],3)
%%
% But called in this way they keep the table type so many functions this
% don't work, ie ('sum(items([1:5],3))')

%%
% Instead used the name of the column rather than the index
items.value([1:5])
%%
sum(items.value([1:5]))
%% 

%% Logical indexing
% Selecting items in a matrix can be done either with a positive interger
% index, or with a boolean string

%%
% Using the index
items.value([1:5])

%%
% Using a boolean string
selection = false(1,length(items.value)); % create a 1 X length vector of falses
selection(1:2:10) = true % make every other index true up to 10 true
%%
items(selection,:)
%%
sum(items.value(selection))
%%
% *NOTE:* this has to be a 'logical' index -- otherwise Matlab wouldn't
% know whether you meant 1 as in true or 1 as in the first index
%
% So if you have something like this
selection = zeros(1,length(items.value)); % create a 1 X length vector of zeros
selection(2:2:10) = 1 % make every other index true up to 10 1
%%
% Be sure to put cast it as a logical
sum( items.value( logical(selection) ) )