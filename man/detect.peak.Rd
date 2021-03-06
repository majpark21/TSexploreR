% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{detect.peak}
\alias{detect.peak}
\title{detect.peak}
\usage{
detect.peak(x, window.size, what = "maxi")
}
\arguments{
\item{x}{numerical vector}

\item{window.size}{integer, width of rolling window.}

\item{what}{character indicating whether maxima or minima should be looked
for. One of c('maxi', 'mini').}
}
\value{
A logical vector. TRUE indicates a local maxima/minima. NAs are
  padded at the extremeties to keep same length as x.
}
\description{
Detect peaks by identifying local maxima/minima in a rolling window.
}
\examples{
x <- sin(seq(0,25,0.1))
plot(x)
abline(v = which(detect.peak(x, 7, "maxi")), col = 'red', lty = 'dashed')
abline(v = which(detect.peak(x, 7, "mini")), col = 'blue', lty = 'dashed')

}
