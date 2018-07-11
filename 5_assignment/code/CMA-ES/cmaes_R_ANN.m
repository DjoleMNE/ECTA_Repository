%% Recurrent ANN with Hidden Nodes
function [output, nodeAct] = cmaes_R_ANN(input_vector, past_act, weight_matrix, p)
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
nodeAct = tanh(nodeAct * wMat);

% Samples X Num_Output_Nodes 
output = nodeAct( (end - p.output_size + 1) : end);
% disp(output);