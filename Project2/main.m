%% Fractal boundary via 1D bisection along vertical lines x = const
% Uses indicator: +1 (outside / escapes), -1 (inside / no escape by max_iter)
% Bisection runs a fixed number of iterations and returns the final midpoint

clear; clc;

%  sampling setup
Nx = 1200;                        % >= 1e3 samples
xs = linspace(-2, 1, Nx);
ys = nan(size(xs));               % upper boundary y (NaN if no crossing found)

% bounds for vertical search along y
y_lower_inside = 0;               % per instructions: lower bound = inside (y = 0)
y_upper_guess  = 2;               % initial guess for outside
y_upper_cap    = 16;              % maximum y to search upward for outside

%  iterate over vertical lines 
for k = 1:numel(xs)
    xk = xs(k);
    fn = indicator_fn_at_x(xk);   % indicator along this vertical line

    % Ensure the lower bound is inside (as required by bisection)
    if fn(y_lower_inside) ~= -1
        % If y=0 is not inside for this x, we skip (no interior on real axis here)
        ys(k) = NaN;
        continue;
    end

    % Find an outside point above: expand upward if needed
    e = y_upper_guess;
    while fn(e) ~= +1 && e <= y_upper_cap
        e = e * 2;                % exponential search upward for an outside point
    end

    if fn(e) ~= +1
        % Could not bracket a sign change (inside at 0, but no outside found up to cap)
        ys(k) = NaN;
        continue;
    end

    % Bisection between inside s=0 and outside e to locate the boundary
    ys(k) = bisection(fn, y_lower_inside, e);
end

% visualize (upper and mirrored lower) 
figure; hold on; box on; grid on;
plot(xs, ys, '.', 'MarkerSize', 6);
plot(xs, -ys, '.', 'MarkerSize', 6);   % mirror for the lower branch (Mandelbrot symmetry)
xlabel('x'); ylabel('y');
title('Approximate fractal boundary for x \in [-2, 1]');
legend({'upper boundary','lower (mirror)'}, 'Location','best');
hold off;


%%  Helper functions 
function m = bisection(fn_f, s, e)
%  Finds the boundary point where fn_f changes sign.
% Inputs:
%   fn_f - indicator function returning -1 (in set) or +1 (out of set)
%   s    - lower bound (inside the set)
%   e    - upper bound (outside the set)
% Output:
%   m    - midpoint of the final interval after fixed iterations

    max_iter = 100;  % fixed number of refinement steps

    for i = 1:max_iter
        m = (s + e) / 2;
        if fn_f(m) > 0
            % midpoint outside -> move upper bound down
            e = m;
        else
            % midpoint inside -> move lower bound up
            s = m;
        end
    end

    % explicitly return midpoint of final interval
    m = (s + e) / 2;
end

function fn = indicator_fn_at_x(x)
% Returns +1 (outside, escapes before max_iter) and -1 (inside, no escape by max_iter)
% along the vertical line at fixed x.
    fn = @(y) (fractaal(complex(x, y)) < 100) * 2 - 1;
end

function it = fractaal(c)
% Computes the number of iterations until |z| > 2.0 (Mandelbrot escape test)
% input:  c - complex number (point in the complex plane)
% output: it - number of iterations before |z| > 2.0 (max 100)
    max_iter = 100;
    z = 0;

    for it = 1:max_iter
        z = z^2 + c;
        if abs(z) > 2
            return;
        end
    end

    % If |z| never exceeded 2 within max_iter, return max_iter (treat as "inside")
    it = max_iter;
end

function l = poly_len(p, s, e, mu)
    if nargin < 4
        dp = polyder(p);
        ds = @(x) sqrt(1 + (polyval(dp, x)).^2);
        l = integral(ds, s, e);
    else
        mu_x = mu(1);
        sigma_x = mu(2);
        dp = polyder(p);
        ds = @(x) sqrt(1 + (polyval(dp, (x - mu_x)/sigma_x) .* (1/sigma_x)).^2);
        l = integral(ds, s, e);
    end
end

%%  Polynomial function fitting
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
%% Arc length calculation
% Test poly_len on y=x
p_test = [1 0];
L_test = poly_len(p_test, 0, 1);
fprintf('[poly_len test] line y=x, expected %.4f, got %.4f\n', sqrt(2), L_test);

% Fractal boundary curve length
s = min(x_core);
e = max(x_core);
L_fractal = poly_len(p, s, e, mu);
fprintf('[Fractal boundary length] L = %.4f (approx.)\n', L_fractal);
