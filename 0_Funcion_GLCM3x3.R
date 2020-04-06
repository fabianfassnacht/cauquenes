## R-Script - GLCM function
## author: Andrés Ceballos Comisso
## mail: aceballos@ug.uchile.cl / fabianewaldfassnacht@gmail.com
## Manuscript: Using Multi-Sensor Data to Derive a Landscape-Level Biomass Map Covering Multiple Vegetation Types
## last changes: 30.07.2014
##


#-------------------------------------------------------------------------------------------------------#
#######     Apply GREY LEVEL CO-OCURRENCE MATRIX  3x3
#-------------------------------------------------------------------------------------------------------#
 
GLCM3x3 <- function(stack, path, stats){
  #stack = RasterStack: Input raster stack for which GLCM metrics will be calculdated
  #path = Character: home directory where a new directory will be created to store results
  #stat = Character vector: GLCM metrics to be calculated (see ?glcm in R for available metrics)
library(glcm) ; require(glcm)
library(raster)
library(rgdal)
  # create new folder to store results	
  raiz = file.path(path,"GLCM3x3/")
  dir.create(path = raiz,showWarnings = FALSE)
  sufix = paste("_3x3",substr(stats, start=1, stop=3),sep="_") ; sufix #create sufix to add to raster names
  
  for(i in 1:nlayers(stack)){  #start iteration to calculate glcm for all bands in the raster stack
    # GLCM de 3x3
      GLCM <- glcm(x = stack[[i]],
                       n_grey=32,
                       window=c(3,3),
                       shift=list(c(0,1),c(1,1),c(1,0),c(1,-1)),
                       statistics=stats,
                       na_opt="ignore",
                       na_val=NA,
                       scale_factor=1,
                       asinteger=FALSE)
    
      for(h in 1:nlayers(GLCM)){ # store all created glcm metrics
        nam = paste0("/",names(stack[[i]]),sufix[h],".tif")
        raster::writeRaster(x = GLCM[[h]],filename = paste0(raiz,nam) , format = "GTiff", overwrite = T)
      } # end of storing
    print(paste(i,"de",nlayers(stack)))
  } # all bands processed   
} # End of function