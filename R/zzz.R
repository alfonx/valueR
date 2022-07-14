
.onAttach <- function(libname, pkgname) {
  
  options(
    apiur.quiet = F
  )
  
      tryCatch(
        {
          packageStartupMessage(valuer_access())

        },
        error=function(e) {
          message("Please connect with valuer_access() to AVM or ANALYST.")
        })

  }

.onUnload <- function(libpath) {

}
