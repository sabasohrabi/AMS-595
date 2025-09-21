# Project1 Description

## Task 1

This script estimates π using a Monte Carlo approach. It generates uniformly random points within the unit square and counts how many fall inside the inscribed quarter circle. The ratio of points inside the circle to the total number of points is used to estimate π, based on the area relationship between the circle and the square. The script tracks the running estimate, the absolute error compared to MATLAB’s value of π, and the cumulative runtime. As the number of samples increases, the estimate converges toward π, the error decreases at a rate proportional to 1/N, and the runtime grows approximately linearly with the number of points.

## Task 2

Each batch of points is treated as a series of binomial trials (inside vs. outside the quarter circle). The proportion of points inside is converted to an estimate of π using the area ratio. A 95% confidence interval for the estimate is calculated using the normal approximation (z ≈ 1.96). The process continues in a while-loop until the relative half-width of the confidence interval falls below a user-specified threshold. At that point, the script reports the final estimate, the width of the confidence interval, and the total number of samples used. This stopping rule is based on the confidence interval width and takes advantage of the 1/N decay in Monte Carlo uncertainty, without ever referencing the true value of π.

## Task 3

The problem is approached by modeling π-estimation as a Monte Carlo “dartboard” experiment, using a confidence interval-based stopping rule rather than a fixed sample size. The function repeatedly generates random points in the unit square, counts the proportion inside the quarter circle, and estimates π accordingly. After each batch, it computes a 95% confidence interval for the estimate and stops once the relative half-width meets the user’s desired precision, achieving the target accuracy without using the true value of π.
