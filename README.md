
# valueR

<!-- badges: start -->
<!-- badges: end -->

The goal of valueR is to facilitate access to real estate market data from VALUE AG's Market Data team via our API interfaces with R.  

## Development

The basis of this package are R functions that we have used for our own access to our data and that we would like to make available to our users. The package is still under development and we are happy to receive hints on enhancements to the functionality.

## Installation

You can install the development version of valueR from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Immobrain/valueR")
```

## Usage

To load the package, run

``` r
library(valueR)
```


## API

With valueR you can access to of our REST-APIs:

##### **ANALYST** 

VALUE ANALYST is based on our real estate market database, which provides up-to-date and comprehensive information on prices, rents and yields of the German real estate market. 

##### **AVM**  

VALUE AVM is a fully comprehensive solution for automated value indication and system-supported derivation of market and lending values.

## ACCESS

To access VALUE Analyst and VALUE AVM you need a license with individual access data for each. 


