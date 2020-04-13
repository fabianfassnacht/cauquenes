gam_nice_plot <- function(gam_model, data){
  
  # get variables used in the gam model
  z <- attr(gam_m_pr$terms, "term.labels")
  
  # create empty list to store new data to
  # predict to
  newdata <- list()
  
  # create new data to predict to
  for (ip in 1:length(z)){
    maxv<-max(gam_prad[,z[ip]])
    minv<-min(gam_prad[,z[ip]])
    v.seq<-seq(minv, maxv, length=300)
    v.df <- data.frame(v.seq)
    names(v.df) <- z[ip]
    newdata[[ip]] <- v.df
  }
  
  # merge new data of all variables into dataframe
  newdata2 <- do.call(cbind, newdata)  
  
  # predict gam model to new data
  preds<-predict(gam_model, type="terms", newdata=newdata2,
                 se.fit=TRUE)
  
  # get fitted values and standard deviations
  newdata3 <- list()
  for (ip2 in 1:length(z)){
    v <- newdata2[,ip2]
    vfit <- preds$fit[,ip2]
    vfit.up95 <- vfit-1.96*preds$se.fit[,ip2]   
    vfit.low95 <- vfit+1.96*preds$se.fit[,ip2]
    newdata3[[ip2]] <- data.frame(vfit,vfit.up95,vfit.low95)
  }
  
  # get number of predictors to define layout of plot
  getnrnc <- ceiling(sqrt(length(z))) 
  
  #x11()
  par(mfrow=c(getnrnc-1,getnrnc), mar=c(4,4,2,4), oma=c(1,0.5,0.5,0.5))
  
  # now plot response curves for all predictors
  for(ip3 in 1:length(z)){
    
    # calculate residuals
    pred.orig<-predict(gam_model, type="terms")
    partial.resids<-pred.orig+residuals(gam_model)
    
    # plot response curves (dont show yet)
    dum <- newdata3[[ip3]]
    plot(newdata2[,ip3], dum[,1], type="n", lwd=3,
         main="", ylim = c(min(partial.resids), max(partial.resids)),
         ylab=paste0(z[ip3], " (", round(sum(gam_model$edf[-1]),2), ")", sep=""), xlab=paste0(z[ip3]))
    
    # plot standard deviations
    polygon(c(newdata2[,ip3], rev(newdata2[,ip3])), 
            c(dum[,2],rev(dum[,3])), col="grey",
            border=NA)
    
    # plot curve
    lines(newdata2[,ip3], dum[,1],  lwd=2)
    
    # add partial residuals.
    
    points(data[,z[ip3]], partial.resids[,ip3], pch=16, col=rgb(0, 0, 1, 0.25))
    
    # if you want to add the rug plot
    rug(data[,z[ip3]])
  }
  
}
