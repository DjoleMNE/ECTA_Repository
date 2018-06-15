function plotfoil(individual, n_param)

[foil, nurbs] = pts2ind(individual,n_param.numEvalPts);

% Visualize
figure(1);
plot(n_param.nacafoil(1,:),n_param.nacafoil(2,:), 'LineWidth', 3);
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
end