computeDisc <- function(cf, cf2,
                        real=TRUE, real2 = TRUE,
                        smeared=FALSE, smeared2=FALSE,
                        subtract.vev=TRUE, subtract.vev2=TRUE,
                        subtract.equal = TRUE,
                        use.samples, use.samples2,
                        type="cosh", verbose=FALSE) {
  stopifnot(inherits(cf, 'cf_meta'))
  stopifnot(inherits(cf, 'cf_orig'))

  T <- cf$Time
  ## extract the corresponding part of the correlation matrix
  tcf <- cf$cf
  if(smeared) {
    tcf <- cf$scf
  }
  if(!real) tcf <- cf$icf
  if(!real && smeared) tcf <- cf$sicf
  
  nrSamples <- cf$nrSamples
  nrSamples2 <- nrSamples
  if(!missing(use.samples) && !(use.samples > nrSamples) && (use.samples > 0) ) {
    nrSamples <- use.samples
  }
  sindex <- c(1:nrSamples)
  obs2 <- cf$obs
  conf.index <- cf$conf.index
  
  ## number of gauges
  N <- dim(tcf)[3]
  ## index array for t
  i <- c(1:T)
  ## index array for t'
  i2 <- i
  ## space for the correlator
  Cf <- array(NA, dim=c(N, T/2+1))

  vev <- 0.
  ## compute vev first
  ## mean over all gauges and times
  if(nrSamples == 1) vev <- mean(tcf)
  else vev <- mean(tcf[,sindex,])
  if(verbose) cat("vev1 = ", vev, "\n")

  if(!subtract.vev) vev <- 0.

  if(missing(cf2)) {
    ## here we compute the actual correlation
    if(nrSamples != 1) {
      ## re-order data
      mtcf <- tcf - vev
      ## average over samples, tcf has dim(T,N)
      tcf <- apply(mtcf[,sindex,], c(1,3), sum)
    }
    else{
      subtract.equal <- FALSE
      tcf <- tcf[,1,] - vev
    }
    ## need to run only to T/2 because source and sink are equal
    ## only possible type is cosh
    for(dt in c(0:(T/2))) {
      Cf[,1+dt] <- apply(tcf[i,]*tcf[i2,], 2, mean)
      ## subtract product of equal samples
      if(subtract.equal) Cf[,1+dt] <- Cf[,1+dt] - apply(apply(mtcf[i,sindex,]*mtcf[i2,sindex,], c(2,3), mean), 2, sum)
      ## shift the index array by 1 to the left
      i2 <- (i2) %% T + 1
    }
    if(subtract.equal) Cf <- Cf/nrSamples/(nrSamples-1)
    else Cf <- Cf/nrSamples/(nrSamples)
  }
  ## now the more general case case of cross-correlators
  else {
    sign <- +1
    if(type != "cosh") sign <- -1
    
    nrSamples2 <- cf2$nrSamples
    if(!missing(use.samples2) && !(use.samples2 > nrSamples2) && (use.samples2 > 0) ) {
      nrSamples2 <- use.samples2
    }

    sindex2 <- c(1:nrSamples2)
    obs2 <- cf2$obs
    ## sanity checks
    if(nrSamples != nrSamples2 && subtract.equal) {
      warning("samples numbers are not equal for cf and cf2\n Setting subtract.equal = FALSE\n")
      subtract.equal <- FALSE
    }
    if(nrSamples == 1 && nrSamples2 == 1 && subtract.equal) {
      warning("samples numbers for both cf and cf2 equal to 1\n Setting subtract.equal = FALSE\n")
      subtract.equal <- FALSE
    }
    if(cf2$Time != T) {
      stop("time extend in two loops does not agree... Aborting...!\n")
    }
    if(!real2 && smeared2) tcf2 <- cf2$sicf
    else if(!real2) tcf2 <- cf2$icf
    else if(smeared2) tcf2 <- cf2$scf
    else tcf2 <- cf2$cf

    ## compute vev2 now
    ## mean over all gauges and times
    vev2 <- 0.
    if(nrSamples2 == 1) vev2 <- mean(tcf2)
    else vev2 <- mean(tcf2[,sindex2,])
    if(verbose) cat("vev2 = ", vev2, "\n")
    if(!subtract.vev2) vev2 <- 0.

    ## now we check using conf.index whether the data sets are matched
    ## we remove any non matched entries
    if(any(!(cf$conf.index %in% cf2$conf.index))) {
      missing.ii <- which(!(cf$conf.index %in% cf2$conf.index))
      tcf <- tcf[,,-missing.ii]
      cf$conf.index <- cf$conf.index[-missing.ii]
      warning(paste("removed config", missing.ii, "from data set cf, it could not be matched\n"))
    }
    if(any(!(cf2$conf.index %in% cf$conf.index))) {
      missing2.ii <- which(!(cf2$conf.index %in% cf$conf.index))
      tcf2 <- tcf2[,,-missing2.ii]
      cf2$conf.index <- cf2$conf.index[-missing.ii]
      warning(paste("removed config", missing.ii, "from data set cf2, it could not be matched\n"))
    }
    if(dim(tcf2)[3] != dim(tcf)[3]) {
      stop("number of gauges for the two loops does not agree... Aborting...!\n")
    }
    ## the unique matched configuration number index
    N <- dim(tcf2)[3]
    conf.index <- unique(cf2$conf.index, cf$conf.index)
    Cf <- array(NA, dim=c(N, T/2+1))
    
    ## re-order data
    ## and average over samples, tcf and tcf2 have then dim(T,N)
    if(nrSamples != 1) {
      mtcf <- tcf - vev
      tcf <- apply(mtcf[,sindex,], c(1,3), sum)
    }
    else {
      tcf <- tcf[,1,] - vev
    }
    if(nrSamples2 != 1) {
      mtcf2 <- tcf2 - vev2
      tcf2 <- apply(mtcf2[,sindex2,], c(1,3), sum)
    }
    else {
      tcf2 <- tcf2[,1,] - vev2
    }

    ## finally we correlate
    for(dt in c(0:(T/2))) {
      ## here we do the time average (t and T-1) in the same step
      Cf[,1+dt] <- apply(0.5*(tcf[i,]*tcf2[i2,] + sign*tcf2[i,]*tcf[i2,]), 2, mean)
      ## subtract product of equal samples
      if(subtract.equal) Cf[,1+dt] <- Cf[,1+dt] -
        apply(apply(0.5*(mtcf[i,sindex,]*mtcf2[i2,sindex2,] + sign*mtcf2[i,sindex2,]*mtcf[i2,sindex,]),
                    c(2,3), mean), 2, sum)
      ## shift the index array by 1 to the left
      i2 <- (i2) %% T + 1
    }
    if(nrSamples2 == nrSamples) {
      if(subtract.equal) Cf <- Cf/nrSamples/(nrSamples-1)
      else Cf <- Cf/nrSamples/nrSamples
    }
    else {
      ## subtract.equal must be FALSE here
      Cf <- Cf/nrSamples/nrSamples2
    }
  }
  ret <- list(cf=Cf, Time=T, nrStypes=1, nrObs=1, nrSamples=nrSamples, nrSamples2=nrSamples2, obs=cf$obs, obs2=obs2, boot.samples=FALSE, conf.index=conf.index)
  attr(ret, "class") <- c("cf", class(ret))
  return(invisible(ret))
}

## finding missing configs
## if(any(!(cf$conf.index %in% cf2$conf.index)))
##    missing.ii <- which(!(cf$conf.index %in% cf2$conf.index))
##    missingcf2 <- cf$conf.index[!(cf$conf.index %in% cf2$conf.index)]
