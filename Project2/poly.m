
%% Polynomial function fitting
% Hand-tune the x-range to discard flat/fringe regions (adjust as needed)
x_min = -2.0;
x_max =  0.5;

% Keep only valid boundary points in the tuned range
keep = ~isnan(ys) & xs >= x_min & xs <= x_max;
x_core = xs(keep);
y_core = ys(keep);

if numel(x_core) < 30
    warning('Too few boundary points in the selected x-range. Consider widening or shifting x_min/x_max.');
end

% Fit a 15th-order polynomial y = f(x) to the (x_core, y_core) points
order = 15;
[p, S, mu] = polyfit(x_core, y_core, order);   % centered/scaled for numerical stability

% Evaluate the fit on a dense grid over the same core x-range
xx = linspace(min(x_core), max(x_core), 2000);
yy = polyval(p, xx, [], mu);

% Plot: overlay polynomial fit on top of the sampled boundary points
figure; hold on; box on; grid on;
plot(x_core, y_core, 'b.', 'DisplayName', 'Boundary Data (upper)');
plot(xx, yy, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Order-%d Poly Fit', order));

% (Optional) also show the mirrored lower branch (data only) for context
plot(x_core, -y_core, 'c.', 'DisplayName', 'Boundary Data (lower mirror)');

xlabel('x'); ylabel('y');
title(sprintf('Polynomial Fit of Mandelbrot Upper Boundary (Order %d)', order));
legend('Location','best');

% (Optional) report basic fit diagnostics
rmse = sqrt(mean((polyval(p, x_core, [], mu) - y_core).^2));
fprintf('Order-%d fit: RMSE = %.6g over [%g, %g] with %d points.\n', order, rmse, min(x_core), max(x_core), numel(x_core));

% (Optional) save coefficients and scaling for later use (e.g., arc length)
% save('boundary_poly_fit.mat','p','S','mu','x_core','y_core');