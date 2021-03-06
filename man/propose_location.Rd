% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bayesian_optimization.R
\name{propose_location}
\alias{propose_location}
\title{Propose Sampling Location}
\usage{
propose_location(
  acquisition,
  gpr,
  lower,
  upper,
  n_restarts = 25,
  xi = 0.01,
  max = TRUE
)
}
\arguments{
\item{acquisition}{The acquisition function to be used.}

\item{gpr}{a fitted gaussian process object containing \code{X_train} and \code{Y_train}.}

\item{lower}{the lower bounds of each variable in \code{X}.}

\item{upper}{the upper bounds of each variable in \code{X}.}

\item{n_restarts}{the number of iterations to find the optimum acquisition.}

\item{xi}{exploitation-exploration trade-off parameter.}

\item{max}{if TRUE we want to maximize the fitness function, otherwise minimize.}
}
\value{
Location of the acquisition function maximum.
}
\description{
Proposes the next sampling point by optimizing the acquisition function.
}
\examples{
noise <- 0.4
gpr <- gpr.init(sigma_y = noise)

# Noisy training data
X_train <- seq(-3, 3, 1)
Y_train <- sin(X_train) + noise * rnorm(n = length(X_train))
gpr <- gpr.fit(X_train, Y_train, gpr)

# Obtain next sampling point from the acquisition function
lower <- c(-5, -5)
upper <- c(5, 5)
X_next <- propose_location(expected_improvement, gpr, lower, upper)
}
