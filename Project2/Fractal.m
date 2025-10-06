clc
clear
close all
%%
function it = fractal(c)
% Computes the number of iterations until |z| > 2.0
% input:  c - complex number
% output: it - number of iterations before |z| > 2.0 (max 100)

    max_iter = 100;
    z = 0;
   
    for it = 1:max_iter
        z = z^2 + c;
        if abs(z) > 2
            return;
        end
    end

    % If |z| never exceeded 2 within max_iter, return max_iter
    it = max_iter;
end

%%
xRange = linspace(-2, 1, 500);   % Real axis
yRange = linspace(-1.5, 1.5, 500); % Imag axis

% Preallocate result matrix
M = zeros(length(yRange), length(xRange));

% Loop over each point in the grid
for ix = 1:length(xRange)
    for iy = 1:length(yRange)
        c = xRange(ix) + 1i*yRange(iy);
        M(iy, ix) = fractal(c); % Call your function
    end
end

% Plot the result
imagesc(xRange, yRange, M);
colormap(hot); % can try 'jet', 'parula', etc.
colorbar;
axis equal;
axis tight;

xlabel('Re(c)');
ylabel('Im(c)');
title('Mandelbrot Set');

% Initialize result matrix
% M = zeros(size(C));

% Compute iteration count for each complex point
for i = 1:resolution
    for j = 1:resolution
        M(i, j) = fractal(C(i, j));
    end
end

% Display the Mandelbrot set
figure;
imagesc(x, y, M);      % scale the axes
axis equal tight;      % Equal scaling 
colormap(flipud(hot))
colorbar;

% Label axes
xlabel('Re(c)', 'FontSize', 12);
ylabel('Im(c)', 'FontSize', 12);
title('Mandelbrot Set', 'FontSize', 14);