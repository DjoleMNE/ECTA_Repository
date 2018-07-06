%% Feed forward ANN w/no Hidden Nodes
%% Inputs: these can be single numbers or vectors
% this is: [nSample X nInputs]
nSample = 1;
nInputs = 3;

inputVector = rand(nSample, nInputs); 
disp('Input Vector Size: '); disp(size(inputVector))

%% Weights for no hidden layers
% [nInputs X nOutputs]
nOutputs = 1; nInputs = 3;
wMat = rand(3,1);
disp('Weight Matrix Size: '); disp(size(wMat))

%% Output
% [nOutputs X nSamples]
output = inputVector*wMat;
disp('Weight Matrix Size: '); disp(size(output))

%% Activation Function
a = tanh(output);

%%--------%%
%% FFNet with Hidden Nodes
% weight matrix takes this form:
%-----
%  Connection From  \ Connection To
%-----
% So with no hidden nodes our (3,1) wMat described weights from the 3
% inputs to the one output node. If we had two outputs our weight matrix
% would be (3,2) with three inputs to two outputs, e.g.
%   wMat= [ (in1 to out1) (in1 to out2)
%           (in2 to out1) (in2 to out2)
%           (in3 to out1) (in3 to out2)]
%
% If you include a hidden node the same conventions should be taken, e.g.
% with a topology with 3 inputs connected to two hidden nodes, and those
% two hidden nodes connected to two outputs
%
%               in1  in2   in3        h1          h2         out1        out2
%   wMat= [ 
%       in1:    0     0     0    (in1 to h1) (in1 to h2)      0           0
%       in2:    0     0     0    (in2 to h1) (in2 to h2)      0           0
%       in3:    0     0     0    (in3 to h1) (in3 to h2)      0           0
%        h1:    0     0     0         0           0       (h1 to out1) (h1 to out2)                                 
%        h2:    0     0     0         0           0       (h2 to out1) (h2 to out2) 
%      out1:    0     0     0         0           0           0           0
%      out2:    0     0     0         0           0           0           0
%         ]
%
%% ---- So in this case:
% Same input vector
clear;
nSample = 1; nInputs = 3;

inputVector = rand(nSample, nInputs); 
disp('Input Vector Size: '); disp(size(inputVector))

%% Weight Matrix 
% [nInputs X nOutputs]
nInputs = 3; nHidden = 2; nOutputs = 2; 
nNode = nInputs+nHidden+nOutputs;
wMat = rand(nNode);
disp('Weight Matrix Size: '); disp(size(wMat))

% This gives you a fully connected network, with weights from every node to
% every other, including themselves. Here are only weights between the 
% inputs and the hidden nodes. Set the weights of connections which do not 
% exist to 0;

wActive = zeros(nNode);
wActive([1 2 3], [4 5]) = 1; % In to Hidden connections
wActive([4 5]  , [6 7]) = 1; % Hidden to Out connections

% Turn inactive connections to 0;
wMat = wMat.*wActive;

%% Activating an Feed Forward ANN
% We calculate the activation of each node per layer. We must know the 
% activation levels of hidden nodes before we can calculate the activation
% of the nodes they feed into. If we have a feed forward network we can
% calculate each nodes activation in order, starting from the input and
% ending at the output.

% Put the input in as the activation of the input nodes
nodeAct = zeros(nSample,nNode);
nodeAct(1:nInputs) = inputVector;

for iNode = (nInputs+1):nNode
    % Here we compute the activation of a node by applying only the 
    % relevant column of the weight matrix, and then apply the
    % activation function, in this case 'tanh', to the result.
   nodeAct(iNode) = tanh(nodeAct*wMat(:,iNode)); 
end

%% Activating a Recurrent Neural Network
% Activating a recurrent neural network with the same weight matrix
% structure is very straight forward. It does not require sequential
% activation and so all weights are activated at once. This can be done
% with a single multiplication:
nInputs = 3; nHidden = 2; nOutputs = 2; 
nNode = nInputs+nHidden+nOutputs;
wMat = rand(nNode); % All weights are active

% Put the input in as the activation of the input nodes
nodeAct = zeros(nSample,nNode);
nodeAct(1:nInputs) = inputVector;

% Each time you multiply the activations by the wMat the activations travel
% across one weight. It is typical to then assign the 'input' nodes the new
% input from the environment.
nodeAct = tanh(nodeAct*wMat); 

nodeAct(1:nInputs) = inputVector;
nodeAct = tanh(nodeAct*wMat);

% That should be enough for you to code ANNS on your own!





