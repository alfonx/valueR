# valueR <img src='inst/logo/hex.png' align="right" height="160" />

The goal of valueR is to facilitate access to real estate market data from VALUE AG's Market Data team via our API interfaces with R.

## Development

The basis of this package are R functions that we have used for our own access to our data and that we would like to make available to our users. The package is still under development and we are happy to receive hints on enhancements to the functionality.

## Installation

You can install the development version of valueR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools", dependencies = T)
devtools::install_github("Immobrain/valueR")
```

## API

With valueR you can access two of our REST-APIs:

##### **ANALYST**

VALUE ANALYST is based on our real estate market database, which provides up-to-date and comprehensive information on prices, rents and yields of the German real estate market. Most users access our database via our GUI "Analyst", we therefore refer to this access as "Analyst" in the context of valueR.

##### **AVM**

VALUE AVM is a fully comprehensive solution for automated value indication and system-supported derivation of market and lending values. With the AVM, different value indications and also object and location parameters can be fetched. The latter are currently not yet implemented in valueR.

## USAGE

To access VALUE Analyst and VALUE AVM you need a license with individual access data for each. Without valid credentials, the use of valueR is pointless. Please contact us if you would like a [trial license](https://www.value-marktdaten.de/en/contact/).

To load the package, run

``` r
library(valueR)
```

You will be asked to provide you credentials using `valuer_access()`:

``` r
Unable to connect to AVM.
Unable to connect to ANALYST.
Please connect with valuer_access() to AVM or ANALYST.
```

To avoid having to enter credentials every time, valueR recognizes the following system variables:

-   VALUER_ANALYST_URL
-   VALUER_ANALYST_USER
-   VALUER_ANALYST_PW
-   VALUER_AVM_URL
-   VALUER_AVM_USER
-   VALUER_AVM_PW

It is highly recommended to set these variable using `Sys.setenv()` in [.Renviron](https://support.rstudio.com/hc/en-us/articles/360047157094-Managing-R-with-Rprofile-Renviron-Rprofile-site-Renviron-site-rsession-conf-and-repos-conf).

Once you have provided your credentials, you will be logged in:

``` r
Connected to AVM: https://avm-api.value-marktdaten.de/v1
Connected to API: https://api.value-marktdaten.de/
```
