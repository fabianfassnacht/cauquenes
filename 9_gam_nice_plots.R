## R-Script - create nice gam plots 

# The script bases on the code provided here:
# http://zevross.com/blog/2014/09/15/recreate-the-gam-partial-regression-smooth-plots-from-r-package-mgcv-with-a-little-style/

## author: Fabian Fassnacht
## mail: fabianewaldfassnacht@gmail.com
## last changes: 15.04.2020
##

# inputs:
## gam_model = object fitted with gcvm::gam function; 
## data = data used in the gam-model; 
## nrr = number of rows in multi-panel plot, nrc = number of columns in multi-panel plot 
## nrr and nrc should be decided based on the number of predictors you use in your gam model


gam_nice_plot <- function(gam_model, data, nrr, nrc){
  
  # get variables used in the gam model
  z <- attr(gam_model$terms, "term.labels")
  
  # create empty list to store new data to
  # predict to
  newdata <- list()
  
  # create new data to predict to
  for (ip in 1:length(z)){
    maxv<-max(data[,z[ip]])
    minv<-min(data[,z[ip]])
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
  

  #x11()
  par(mfrow=c(nrr,nrc), mar=c(4,4,2,4), oma=c(1,0.5,0.5,0.5))
  
  # now plot response curves for all predictors
  for(ip3 in 1:length(z)){
    
    # calculate residuals
    pred.orig<-predict(gam_model, type="terms")
    partial.resids<-pred.orig+residuals(gam_model)
    
    # plot response curves (dont show yet)
    dum <- newdata3[[ip3]]
    # get entries necessary to calculate edf values
    edfval <- str_detect(names(gam_model$edf), z[ip3])
    
    plot(newdata2[,ip3], dum[,1], type="n", lwd=3,
         main="", ylim = c(min(partial.resids), max(partial.resids)),
         ylab=paste0(z[ip3], " (", round(sum(gam_model$edf[edfval]),2), ")", sep=""), xlab=paste0(z[ip3]))
    
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
