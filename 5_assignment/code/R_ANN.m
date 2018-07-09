%% Feed forward ANN with Hidden Nodes
function output = R_ANN(input_vector, weight_matrix, p)
% input_vector = [400.7 6.7 8.0];
% num_hidden   = 2;
% num_output   = 2;
% nSample = 2;
% num_input = 3;
% nNode = num_input + num_hidden + num_output;

% this is: [nSample X nInputs]
% disp('Input Vector Size: '); disp(size(input_vector))

%% Initialization
% weight matrix takes this form:  Connection From  \ Connection To
% [nInputs X nOutputs]
num_input  = p.input_size;
num_hidden = p.num_hidden;
num_output = p.output_size;
nSample    = size(input_vector, 1);
nNode      = p.net_size;
wMat       = weight_matrix;

%% Activating a Recurrent Neural Network
% Activating a recurrent neural network with the same weight matrix
% structure is very straight forward. It does not require sequential
% activation and so all weights are activated at once. This can be done
% with a single multiplication:

% Put the input in as the activation of the input nodes
nodeAct = zeros(nSample, nNode);
nodeAct(:, 1:num_input) = input_vector;

% Each time you multiply the activations by the wMat the activations travel
% across one weight. It is typical to then assign the 'input' nodes the new
% input from the environment.
nodeAct = tanh(nodeAct * wMat); 
nodeAct(:, 1:num_input) = input_vector;
nodeAct = tanh(nodeAct * wMat);

% Samples X Num_Output_Nodes 
output = nodeAct(:, (end - num_output + 1) : end);
% disp(output);