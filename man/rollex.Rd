% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{rollex}
\alias{rollex}
\title{rollex}
\usage{
rollex(x, k = 5)
}
\arguments{
\item{x}{a numerical vector}

\item{k}{integer, width of the window for rolling mean}
}
\value{
A numerical vector of same length as x.
}
\description{
Extended rolling mean, fill the extremeties with linear extrapolation. This
way the output has same length as the original vector.
}
\examples{
# Sinusoid + Gaussian white noise
x <- sin(seq(0,30,0.05))
x <- x + rnorm(length(x), mean = 0, sd = 0.2)
x_rollex <- rollex(x, k = 3)
plot(x)
lines(x_rollex, col = 'blue', lwd = 2)
}
