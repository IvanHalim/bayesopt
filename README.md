Portfolio Allocation using Bayesian Optimization
================

The purpose of this project is to gain a deeper understanding of
Bayesian Optimization and its practical application in data analysis and
simulation. Bayesian Optimization is an increasingly popular topic in
the field of Machine Learning. It allows us to find an optimal
hyperparameter configuration for a particular machine learning algorithm
without too much human intervention. Bayesian Optimization has several
advantages compared to other optimization algorithm. The first advantage
of Bayesian Optimization is that it does not require hand-tuning or
expert knowledge, which makes it easily scalable for larger, more
complicated analysis. The second advantage of Bayesian Optimization is
when evaluations of the fitness function are expensive to perform. If
the fitness function ![equation](https://latex.codecogs.com/gif.latex?f)
is cheap to evaluate we could sample at many points e.g. via grid
search, random search or numeric gradient estimation. However, if
function evaluation is expensive e.g. tuning hyperparameters of a deep
neural network, probe drilling for oil at given geographic coordinates
or evaluating the effectiveness of a drug candidate taken from a
chemical search space then it is important to minimize the number of
samples drawn from the black box function
![equation](https://latex.codecogs.com/gif.latex?f).

## Project Organization

  - The `analysis` folder contains Rmarkdown files (along with knitted
    versions for easy viewing) with the code used to run simulations and
    analyze and visualize the results.

  - The `data` folder contains the New York Stock Exchange dataset used
    for this simulation. Data is imported from Kaggle (
    <https://www.kaggle.com/dgawlik/nyse> ).

  - The `R` folder contains the R functions used to run Bayesian
    Optimization

  - The `reports` folder contains deliverables such as project proposal
    and final report.

  - The `results` folder contains files generated files generated during
    clean-up and analysis as well as the final result of the simulation.

  - The `man` folder contains documentation for the functions defined in
    the `R` folder. Documentation for each function can be rendered
    using the standard R syntax (e.g. `?function`).

## Gaussian Process

Gaussian Process is a probabilistic model to approximate based on a
given set of data points. Gaussian Process models a function as a set of
random variables whose joint distribution is a multivariate normal
distribution, with a specific mean vector and covariance
matrix.

![equation](https://latex.codecogs.com/gif.latex?f%28x_%7B1%3Ak%7D%29%20%5Csim%20%5Cmathcal%7BN%7D%28%5Cmu%28x_%7B1%3Ak%7D%29%2C%20%5CSigma%28x_%7B1%3Ak%7D%2Cx_%7B1%3Ak%7D%29%29)

Where,

  - ![equation](https://latex.codecogs.com/gif.latex?%5Cmathcal%7BN%7D%28x%2Cy%29):
    Gaussian/Normal random
    distribution
  - ![equation](https://latex.codecogs.com/gif.latex?%5Cmu%28x_%7Bi%3Ak%7D%29):
    Mean vector of each
    ![equation](https://latex.codecogs.com/gif.latex?f%28x_i%29)
  - ![equation](https://latex.codecogs.com/gif.latex?%5CSigma%28x_%7Bi%3Ak%7D%2C%20x_%7Bi%3AK%7D%29):
    Covariance matrix of each pair of
    ![equation](https://latex.codecogs.com/gif.latex?f%28x_i%29)

For a candidate point
![equation](https://latex.codecogs.com/gif.latex?x%27), its function
value ![equation](https://latex.codecogs.com/gif.latex?f%28x%27%29) can
be approximated, given a set of observed values
![equation](https://latex.codecogs.com/gif.latex?f%28x_%7B1%3An%7D%29),
using the posterior
distribution,

![equation](https://latex.codecogs.com/gif.latex?f%28x%27%29%7Cf%28x_%7B1%3An%7D%29%20%5Csim%20%5Cmathcal%7BN%7D%28%5Cmu_n%28x%29%2C%20%5Csigma_n%5E2%28x%29%29)

Where,

  - ![equation](https://latex.codecogs.com/gif.latex?%5Cmu_n%28x%29%20%3D%20%5CSigma_0%28x%2Cx_%7Bi%3An%7D%29%20%5Cast%20%5CSigma_0%28x_%7Bi%3An%7D%2Cx_%7Bi%3An%7D%29%5E%7B-1%7D%20%5Cast%20%28f%28x_%7B1%3An%7D%29%20-%20%5Cmu_0%28x_%7B1%3An%7D%29%29%20+%20%5Cmu_0%28x%29)
  - ![equation](https://latex.codecogs.com/gif.latex?%5Csigma_n%5E2%28x%29%20%3D%20%5CSigma_0%28x%2Cx%29%20-%20%5CSigma_0%28x%2C%20x_%7Bi%3An%7D%29%20%5Cast%20%5CSigma_0%28x_%7Bi%3An%7D%2Cx_%7Bi%3An%7D%29%5E%7B-1%7D%20%5Cast%20%5CSigma_0%28x_%7Bi%3An%7D%2Cx%29)

Below is the example of Gaussian Process posterior over function graph.
The following example draws three samples from the posterior and plots
them along with the mean, confidence interval and training data.

``` r
noise <- 0.4
gpr <- gpr.init(sigma_y = noise)

# Finite number of points
X <- seq(-5, 5, 0.2)

# Noisy training data
X_train <- seq(-3, 3, 1)
Y_train <- sin(X_train) + noise * rnorm(n = length(X_train))
gpr <- gpr.fit(X_train, Y_train, gpr)

# Compute mean and covariance of the posterior predictive distribution
result <- gpr.predict(X, gpr)
mu_s <- result$mu_s
cov_s <- result$cov_s

samples <- mvrnorm(n = 3, mu = mu_s, Sigma = cov_s)
plot_gp(mu_s, cov_s, X, X_train, Y_train, samples)
```

![](README_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

## Acquisition Function

Acquisition function is employed to choose which point of
![equation](https://latex.codecogs.com/gif.latex?x) that we will take
the sample next. The chosen point is those with the optimum value of
acquisition function. The acquisition function calculate the value that
would be generated by evaluation of the fitness function at a new point
![equation](https://latex.codecogs.com/gif.latex?x), based on the
current posterior distribution over
![equation](https://latex.codecogs.com/gif.latex?f).

Acquisition function tries to find the balance between exploitation and
exploration. Exploitation means sampling where the surrogate model
predicts a high objective and exploration means sampling at locations
where the prediction uncertainty is high. Both correspond to high
acquisition function values and the goal is to maximize the acquisition
function to determine the next sampling point.

Below is the illustration of the acquisition function value curve. The
value is calculated using expected improvement method. Point with the
highest value of the acquisition function will be sampled at the next
round/iteration.

<img src="figures/acquisition_function.png">

There are several choice of acquisition function, such as expected
improvement, upper confidence bound, entropy search, etc. Here we will
be using the expected improvement
function.

![equation](https://latex.codecogs.com/gif.latex?EI%28x%29%20%3D%20%5Cbegin%7Bcases%7D%20%28%5Cmu%28x%29%20-%20f%28x%5E+%29%20-%20%5Cxi%29%5CPhi%28Z%29%20+%20%5Csigma%28x%29%5Cphi%28Z%29%20%26%20%5Cmbox%7Bif%20%7D%20%5Csigma%28x%29%20%3E%200%20%5C%5C%200%20%26%20%5Cmbox%7Bif%20%7D%20%5Csigma%28x%29%20%3D%200%20%5Cend%7Bcases%7D)

Where,

![equation](https://latex.codecogs.com/gif.latex?Z%20%3D%20%5Cfrac%7B%5Cmu%28x%29%20-%20f%28x%5E+%29%20-%20%5Cxi%7D%7B%5Csigma%28x%29%7D)

  - ![equation](https://latex.codecogs.com/gif.latex?f%28x%5E+%29): Best
    value of
    ![equation](https://latex.codecogs.com/gif.latex?f%28x%29%29) of the
    sample
  - ![equation](https://latex.codecogs.com/gif.latex?%5Cmu%28x%29): Mean
    of the GP posterior predictive at
    ![equation](https://latex.codecogs.com/gif.latex?x)
  - ![equation](https://latex.codecogs.com/gif.latex?%5Csigma%28x%29):
    Standard deviation of the GP posterior predictive at
    ![equation](https://latex.codecogs.com/gif.latex?x)
  - ![equation](https://latex.codecogs.com/gif.latex?%5Cxi): `xi` (some
    call `epsilon` instead). Determines the amount of exploration during
    optimization and higher
    ![equation](https://latex.codecogs.com/gif.latex?%5Cxi) values lead
    to more exploration. A common default value for
    ![equation](https://latex.codecogs.com/gif.latex?%5Cxi) is 0.01.
  - ![equation](https://latex.codecogs.com/gif.latex?%5CPhi): The
    cumulative density function (CDF) of the standard normal
    distribution
  - ![equation](https://latex.codecogs.com/gif.latex?%5Cphi): The
    probability density function (PDF) of the standard normal
    distribution

## Bayesian Optimization

Now we have all components needed to run Bayesian optimization with the
algorithm outlined above.

Bayesian optimization runs for 10 iterations. In each iteration, a row
with two plots is produced. The left plot shows the noise-free objective
function, the surrogate function which is the GP posterior predictive
mean, the 95% confidence interval of the mean and the noisy samples
obtained from the objective function so far. The right plot shows the
acquisition function. The vertical dashed line in both plots shows the
proposed sampling point for the next iteration which corresponds to the
maximum of the acquisition function.

<img src="figures/bayes_opt_illustration.png">
