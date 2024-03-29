% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analyst_meta.R
\name{analyst_meta}
\alias{analyst_meta}
\alias{analyst_status}
\alias{analyst_segments}
\alias{analyst_vars}
\alias{analyst_spatial}
\title{Meta data from API}
\usage{
analyst_status()

analyst_segments(segment = NULL)

analyst_vars(var = NULL, segment = NULL, categories = FALSE)

analyst_spatial(
  type = c("districts", "municipalities", "localities", "states", "u1", "u2", "u3"),
  code = NULL,
  details_state = FALSE,
  details_district = FALSE
)
}
\arguments{
\item{segment}{ID or KEY of the market-segment to show. If specified together with `categories`, categories of the segment only are shown. 
See \href{https://api.value-marktdaten.de/api-docs/}{Swagger Documentation} for all IDs and KEYs available.}

\item{var}{ID or KEY of the variable to show. 
See \href{https://api.value-marktdaten.de/api-docs/}{Swagger Documentation} for all IDs and KEYs available.}

\item{categories}{If TRUE, categories of variable are shown. If TRUE, a `var` of type categorie is required.}

\item{type}{Type of spatial unit, one of \code{c("districts", "municipalities", "localities", "states", "u1", "u2", "u3")}.
Defaults to `districts`.}

\item{code}{Either a `municipality code` for type `municipalities` or a district code for type `districts`.
Will be ignored for other input in `type`.}

\item{details_state}{If TRUE, details about the state are included in results for municipalities and districts.}

\item{details_district}{If TRUE, details about the district are included in results for municipalities.}
}
\value{
Each function returns an object of class \code{data.frame}.
}
\description{
Functions to receive meta data from AVM API.
}
\section{Functions}{
\itemize{
\item \code{analyst_status}: Get information on API status.

\item \code{analyst_segments}: Get information on API segments.

\item \code{analyst_vars}: Get information on API variables.

\item \code{analyst_spatial}: Get information on API spatial variables.
}}

\section{Notes}{
 This function assumes that environment variables `APIUR_USER`, `APIUR_PW` and a valid license exist.
}

\examples{
\dontrun{pdf_docs(endpoint = 'MARKET_VALUE', deploy = TRUE)}
}
\seealso{
\code{\link{analyst_response}}
}
