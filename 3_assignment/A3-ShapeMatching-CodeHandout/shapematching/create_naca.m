function [ foil ] = create_naca( nacaParams, points )
%function [ foil ] = create_naca( chordLength, span, angleAttack, nacaParams, points )

%% CREATE_NACA Creates a 2D naca shape
%     Partially based on NACA2STL script by Håkon Strandenes, hakostra@stud.ntnu.no %
points = 256;
angleAttack = 0;
%span = 0.05;
chordLength = 1;

% Foil geometry
c = chordLength;
%s = span;
alpha = angleAttack;
    
NACA = nacaParams;        % NACA 4-digit designation as a row vector;

% Surface resolution parameters
Ni = points/2;            % Number of interpolation points along the foil

% Create a vector with x-coordinates, camber and thickness
beta=linspace(0,pi,Ni);
x = c*(0.5*(1-cos(beta)));
z_c = zeros(size(x));
z_t = zeros(size(x));
theta = zeros(size(x));

m = NACA(1)/100;
p = NACA(2)/10;
t = (NACA(3)*10 + NACA(4))/100;
z_t = (t*c/0.2) * (0.2969.*(x/c).^0.5 - 0.1260.*(x/c) - 0.3516.*(x/c).^2 + 0.2843.*(x/c).^3 - 0.1036.*(x/c).^4);

if (p > 0)
  % Calculate camber
  z_c = z_c + (m.*x/p^2) .* (2*p - x/c) .* (x < p*c);
  z_c = z_c + (m.*(c-x)/(1-p)^2) .* (1 + x/c - 2*p) .* (x >= p*c);
  % Calculate theta-value
  theta = theta + atan( (m/p^2) * (2*p - 2*x/c) ) .* (x < p*c);
  theta = theta + atan( (m/(1-p)^2) * (-2*x/c + 2*p) ) .* (x >= p*c);
end

% Calculate coordinates of upper surface
Xu = x - z_t.*sin(theta);
Zu = z_c + z_t.*cos(theta);
% Calculate coordinates of lower surface
Xl = x + z_t.*sin(theta);
Zl = z_c - z_t.*cos(theta);

% Rotate foil to specified angle of attack
upper = [cos(alpha), sin(alpha); -sin(alpha), cos(alpha)] * [Xu ; Zu];
lower = [cos(alpha), sin(alpha); -sin(alpha), cos(alpha)] * [Xl ; Zl];
foil = [upper,lower(:,end:-1:1)];
end

