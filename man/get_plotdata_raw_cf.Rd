% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/raw_cf.R
\name{get_plotdata_raw_cf}
\alias{get_plotdata_raw_cf}
\title{extract data from 'raw_cf' in format convenient to plot}
\usage{
get_plotdata_raw_cf(cf, reim, tauint, relerr)
}
\arguments{
\item{cf}{\code{raw_cf} object with meta-data and data.}

\item{reim}{String, one of 'real', 'imag' or 'both'. Specifies
whether the real and/or imaginary parts should be extracted.}

\item{tauint}{Boolean, specifies if the tensor of auto-correlation times
and corresponding errors should be extracted.}

\item{relerr}{Boolean, specifies if the return value should also include
estimates of the relative error and its error.}
}
\value{
List of up to six named elements (depending on what was passed for
\code{reim}, \code{tauint}, \code{relerr}) containing the central
values and errors of the real and/or imaginary part of \code{cf$data}
as well as the corresponding arrays of auto-correlation times and
relative errors. The list elements come in the order
\code{real}, \code{imag}, \code{relerr_real}, \code{relerr_imag},
\code{tauint_real}, \code{tauint_imag} if \code{reim} is \code{both} and
\code{tauint} and \code{relerr} are \code{TRUE}. The \code{val} and
\code{dval} members of these list elements are arrays of dimension
\code{ c( cf$nts, cf$dim ) } and thus lack the first index compared
to \code{cf$data}.
}
\description{
When dealing with with tensorial \code{raw_cf} objects
pre-processing and reshaping is always required to
prepare the data for plotting (or similar). This function
conveniently prepares a named list of prepared data.
The list elements are themselves lists which contain
\code{val} and \code{dval} members with the central value and error
of the element in question. These are in turn
arrays of dimension \code{ c( cf$nts, cf$dim ) } and thus
lack the first index compared to \code{cf$data}.
}
