
.onAttach <- function(libname, pkgname) {
  
  options(
    valuer.quiet = F
  )
  
      tryCatch(
        {
          packageStartupMessage(valuer_access())

        },
        error=function(e) {
        	packageStartupMessage("Please connect with valuer_access() to AVM or ANALYST.")
        })

  }

.onUnload <- function(libpath) {

}

