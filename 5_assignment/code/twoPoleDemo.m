%% This is the physics simulator and FF_ANN tester
function fitness = twoPoleDemo(p, weight_matrix)

% Here is how a state is defined:
%   state = [ x           <- the cart position
%             x_dot       <- the cart velocity
%             theta       <- the angle of the pole
%             theta_dot   <- the angular velocity of the pole.
%             theta2      <- the angle of the 2nd pole
%             thet2a_dot  <- the angular velocity of the 2nd pole.
%           ]
if p.visualize
    fig = figure(1);
end
p.simParams.force = 10.0; % Maximum absolute force 10N
totalSteps = 1000;
initialState = [0 0 .017 0 0.0 0]';  % initial state (note, it is a column vector) (1 degree = .017 rad)
scaling = [ 2.4 10.0 0.628329 5 0.628329 16]'; % Divide state vector by this to scale state to numbers between 1 and 0
state = initialState;
fitness  = 1000;

for step = 1:totalSteps
    % Check that all states are legal
    onTrack = abs(state(1)) < 2.16;
    notFast = abs(state(2)) < 1.35; %The cart is not too fast
    pole1Up = abs(state(3)) < pi/2;
    
    if p.bothPoles
        pole2Up = abs(state(5)) < pi/2;
    else
        pole2Up = true;
    end
    
    failureConditions = ~[onTrack notFast pole1Up pole2Up];
    if any(failureConditions)   
        fitness = step;  disp(failureConditions); break;
%         fitness = step; break;
        
    else % Do the next time step - ACTION SELECTION [your code goes here]
        scaledInput = state./scaling; % Normalize state vector for ANN
        
        % Output should be between -1 (full force left) and 1 (full force right)
        if p.bias_included
            current_state = [scaledInput(1 : p.input_size - 1)' 1];
        else 
            current_state = scaledInput(1 : p.input_size)';
        end
        
        output = ff_ANN(current_state, weight_matrix, p);
        
        if output > 1.0
            output = 1.0;
            disp("Too strong force")
        elseif output < -1.0
            output = -1.0;
            disp("Too strong force")
        end
        action = output * p.simParams.force; % Scale to full force
        
        % Take action and return new state:
        state = cart_pole2(state, action);        
        
        if p.visualize 
            % Visualize result (optional and slow, don't use all the time!)
            %clf
            cpvisual(fig, 1, state(1:4), [-3 3 0 2], action );         % Pole 1
            if p.bothPoles
                cpvisual(fig, 0.5, state([1 2 5 6]), [-3 3 0 2], action );% Pole 2
            end
        end
        
        pause(0.01);
    end
end