%% Polynomial function fitting
x_min = -2.0;
x_max =  0.5;

keep = ~isnan(ys) & xs >= x_min & xs <= x_max;
x_core = xs(keep);
y_core = ys(keep);

if numel(x_core) < 30
    warning('Too few boundary points in the selected x-range.');
end

order = 15;
[p, S, mu] = polyfit(x_core, y_core, order);

xx = linspace(min(x_core), max(x_core), 2000);
yy = polyval(p, xx, [], mu);

figure; hold on; box on; grid on;
plot(x_core, y_core, 'b.', 'DisplayName', 'Boundary Data (upper)');
plot(xx, yy, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Order-%d Poly Fit', order));
plot(x_core, -y_core, 'c.', 'DisplayName', 'Boundary Data (lower mirror)');
xlabel('x'); ylabel('y');
title(sprintf('Polynomial Fit of Mandelbrot Upper Boundary (Order %d)', order));
legend('Location','best');

rmse = sqrt(mean((polyval(p, x_core, [], mu) - y_core).^2));
fprintf('Order-%d fit: RMSE = %.6g\n', order, rmse);

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


%% Helper functions
function m = bisection(fn_f, s, e)
    max_iter = 100;
    for i = 1:max_iter
        m = (s + e) / 2;
        if fn_f(m) > 0
            e = m;
        else
            s = m;
        end
    end
    m = (s + e) / 2;
end

function fn = indicator_fn_at_x(x)
    fn = @(y) (fractaal(complex(x, y)) < 100) * 2 - 1;
end

function it = fractaal(c)
    max_iter = 100;
    z = 0;
    for it = 1:max_iter
        z = z^2 + c;
        if abs(z) > 2
            return;
        end
    end
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
