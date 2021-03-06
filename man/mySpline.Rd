% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{mySpline}
\alias{mySpline}
\title{mySpline}
\usage{
mySpline(x, y, n)
}
\arguments{
\item{x, y}{vectors giving the coordinates of the points to be interpolated.}

\item{n}{interpolation takes place at n equally spaced points spanning the
interval [xmin, xmax]}
}
\value{
A list containing components x and y which give the ordinates where
  interpolation took place and the interpolated values.
}
\description{
Interpolate points of a trajectory by spline. Returns the interpolated points
along with the data in a single trajectory.
}
\details{
Spline interpolation is made according to stats::spline. See doc for
  details and default.
}
\examples{
x <- sin(seq(0,5,0.75))
x_spline <- mySpline(seq_along(x), x, 3*length(x))
plot(seq_along(x), x)
plot(x_spline$x, x_spline$y, type = 'b')

}
