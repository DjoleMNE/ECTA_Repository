%% Feed forward ANN with Hidden Nodes
function [output, nodeAct] = R_ANN(input_vector, past_act, weight_matrix, p)
% input_vector = [400.7 6.7 8.0];
% num_hidden   = 2;
% num_output   = 1;
% nSample        = 1;
% num_input = 3;
% nNode = num_input + num_hidden + num_output;

% this is: [nSample X nInputs]
% disp('Input Vector Size: '); disp(size(input_vector))

%% Initialization
% weight matrix takes this form:  Connection From  \ Connection To
% [nInputs X nOutputs]
nSample    = size(input_vector, 1);
wMat       = weight_matrix;

%% Activating a Recurrent Neural Network
% wMat = rand(p.net_size); % All weights are active

% Put the input in as the activation of the input nodes
nodeAct = zeros(nSample, p.net_size);
nodeAct(1:p.input_size) = input_vector;

%Store past activations of hidden neurons as well
nodeAct(p.input_size + 1 : end) = past_act(p.input_size + 1 : end);
nodeAct = tansig(nodeAct * wMat);

% Samples X Num_Output_Nodes 
output = nodeAct( (end - p.output_size + 1) : end);
% disp(output);