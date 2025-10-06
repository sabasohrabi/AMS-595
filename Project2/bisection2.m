%% Fractal boundary via 1D bisection along vertical lines x = const
% Uses indicator: +1 (outside / escapes), -1 (inside / no escape by max_iter)
% Bisection runs a fixed number of iterations and returns the final midpoint

clear; clc;

% sampling setup 
Nx = 1200;                        % >= 1e3 samples
xs = linspace(-2, 1, Nx);
ys = nan(size(xs));               % upper boundary y 

% bounds for vertical search along y 
y_lower_inside = 0;               % per instructions: lower bound = inside (y = 0)
y_upper_guess  = 2;               % initial guess for outside
y_upper_cap    = 16;              % maximum y to search upward for outside

% vertical lines
for k = 1:numel(xs)
    xk = xs(k);
    fn = indicator_fn_at_x(xk);   % indicator, vertical line

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
% BISECTION Finds the boundary point where fn_f changes sign.
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