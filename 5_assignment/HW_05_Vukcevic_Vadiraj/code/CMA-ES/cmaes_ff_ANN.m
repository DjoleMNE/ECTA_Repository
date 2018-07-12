%% Feed forward ANN with Hidden Nodes
function output = cmaes_ff_ANN(input_vector, weight_matrix, p)
%% FFNet with Hidden Nodes
% weight matrix takes this form:  Connection From  \ Connection To
% [nInputs X nOutputs]
num_input  = p.input_size;
num_hidden = p.num_hidden;
num_output = p.output_size;
nSample    = size(input_vector, 1);
nNode      = p.net_size;
wMat       = weight_matrix;

wActive = zeros(nNode);
wActive(1 : num_input, num_input +1 : num_input + num_hidden) = 1; % In to Hidden connections
wActive(num_input +1 : num_input + num_hidden,...
        num_input + num_hidden +1 : num_input + num_hidden + num_output) = 1; % Hidden to Out connections

% Turn inactive connections to 0;
wMat = wMat .* wActive;

% Activating an Feed Forward ANN
% Put the input values in as the activation of the input nodes
nodeAct = zeros(nSample, nNode);
nodeAct(:, 1:num_input) = input_vector;

for iNode = (num_input + 1): nNode
   nodeAct(:, iNode) = tanh(nodeAct * wMat(:, iNode)); 
end

% Samples X Num_Output_Nodes 
output = nodeAct(:, (end - num_output + 1) : end);