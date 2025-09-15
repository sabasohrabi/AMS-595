Project1 description:

task1 

The script drops uniformly random points in the unit square, counts how many fall inside the inscribed quarter circle, and maps that hit rate to a π estimate via the circle-to-square area ratio. It tracks the running estimate, absolute error (vs MATLAB’s pi), and cumulative runtime. As samples grow, the estimate stabilizes near π, the error shrinks at roughly the Monte Carlo rate 
1
/
N
​	
 , and runtime increases about linearly with the number of points.

 task2

 Each batch treats “inside vs. outside” as a binomial trial, converts the inside proportion 
p
^
  to 
π
^
  via the area ratio, and forms a 95% normal-approximation confidence interval (using 
z≈1.96) to quantify uncertainty. The while-loop continues until the CI’s relative half-width drops below the user’s target, then reports the final estimate, CI width, and total samples. This CI-width stopping rule is principled and leverages the 
1
/
N
​	
  decay of Monte Carlo uncertainty without ever using the true value of π.

  task3

I solved the problem by treating π-estimation as a Monte Carlo “dartboard” experiment and using a confidence-interval stopping rule instead of a fixed sample size. The function repeatedly draws uniform points in the unit square, counts the share inside the inscribed quarter-circle, and maps that hit rate to an estimate of π. After each batch it computes a 95% confidence interval for the estimate and stops as soon as the relative half-width is below a user chosen threshold achieving the requested precision without ever using the true value of π.
