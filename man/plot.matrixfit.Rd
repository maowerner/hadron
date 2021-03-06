% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/matrixfit.R
\name{plot.matrixfit}
\alias{plot.matrixfit}
\title{Plot a matrixfit}
\usage{
\method{plot}{matrixfit}(x, plot.errorband = FALSE, ylim, xlab = "t/a",
  ylab = "y", do.qqplot = TRUE, plot.raw = TRUE, rep = FALSE, col,
  every, ...)
}
\arguments{
\item{x}{an object of class matrixfit}

\item{plot.errorband}{Boolean: whether or not to plot an errorband}

\item{ylim}{Numeric vector: y-limit of the plot}

\item{xlab}{String: label of x-axis}

\item{ylab}{String: label of y-axis}

\item{do.qqplot}{Boolean: whether or not to plot an QQ-plot}

\item{plot.raw}{Boolean: plot the raw data or multiply out the leading exponetial behaviour}

\item{rep}{Boolean: whether or not to add to existing plot}

\item{col}{String vector: vector of colours for the different correlation functions}
}
\description{
Plot a matrixfit
}
\seealso{
\code{\link{matrixfit}}
}
