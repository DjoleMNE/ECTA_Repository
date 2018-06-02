% Create a NACA foil
numEvalPts = 256;                           % Num evaluation points
nacaNum = [0,0,1,2];                        % NACA Parameters
nacafoil= create_naca(nacaNum,numEvalPts);  % Create foil

% Create an individual (consisting of 32 y values between -0.5 and 0.5)
individual = rand(32,1)-0.5;
% Extract spline representation of foil (with the same number of evaluation
% points as the NACA profile
[foil, nurbs] = pts2ind(individual,numEvalPts);

% Calculate pairwise error
half = round(nacafoil/2);
[~,errorTop] =    dsearchn(nacafoil(:,1:end/2)'    ,foil(:,1:end/2)');
[~,errorBottom] = dsearchn(nacafoil(:,1+end/2:end)',foil(:,1+end/2:end)');

% Total fitness (mean squared error)
fitness = mean([errorTop.^2; errorBottom.^2]);

% Visualize
figure(1);
plot(nacafoil(1,:),nacafoil(2,:), 'LineWidth', 3);
hold on;
plot(foil(1,:),foil(2,:), 'r', 'LineWidth', 3);
%plot(nurbs.coefs(1,1:end/2),nurbs.coefs(2,1:end/2),'rx', 'LineWidth', 3);
plot(nurbs.coefs(1,:),nurbs.coefs(2,:),'ko', 'LineWidth', 3);
axis equal;
axis([0 1 -0.7 0.7]);
legend('NACA 0012 target', 'Approximated Shape');
ax = gca;
ax.FontSize = 24;
drawnow;
hold off;