## R-Script - run iterative validation procedure
## author: Fabian Fassnacht 
## mail: fabianewaldfassnacht@gmail.com
## Manuscript: Using Multi-Sensor Data to Derive a Landscape-Level Biomass Map Covering Multiple Vegetation Types
## last changes: 05.04.2020
##

# load packages
require(matrixStats)
require(raster)
require(randomForest)
require(MLmetrics)
require(hydroGOF)

# load final dataframes created in the modeling workflow script
setwd("/home/fabian/Fondecyt/5_outputs/1_dataframes")
list.files()

bn_df <- read.csv("biomasa_BN_predictoras_f.csv")
prad_df <- read.csv("biomasa_PRAD_predictoras_f.csv")
mat_df <- read.csv("biomasa_mattoral_predictoras_f.csv")
pin_df <- read.csv("biomasa_PINO_predictoras_f.csv")

####
#### shrublands
####

# drop outliers
biomasa_matorral_df2 <- mat_df[-c(5,47,49),2:217]

# load VSURF result
setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_mat, file = "vsurf_mat.RData")
load("vsurf_mat.RData")

# check correlations of individual selected predictors
cor(biomasa_matorral_df2[,2],biomasa_matorral_df2[,vrfm_mat$varselect.pred+2], method="spearman") 

# save pair plots
png(filename = "mattoral_pairs.png", width=1200, height=1200, res=300)
pairs(biomasa_matorral_df2[,c(2,(vrfm_mat$varselect.pred+2))]) 
dev.off()

## run iterative validation

# create empty matrix to store results
res_mat_vec <- data.frame(matrix(nrow=100, ncol=3))

# start iterative validation
set.seed(25)
for (i in 1:100){

  # create random sample of the field data (80%)
  samp <- sample(seq(1,nrow(biomasa_matorral_df2),1), round(nrow(biomasa_matorral_df2)*0.8))
  # train model based on the 80% field data
  rfm_it <- randomForest(biomasa_matorral_df2[samp,vrfm_mat$varselect.pred+2], biomasa_matorral_df2[samp,2], ntree=500, importance = T)
  # predict model to hold out samples
  hor <- predict(rfm_it, biomasa_matorral_df2[-samp,vrfm_mat$varselect.pred+2])
  # calculate correlation for hold out sample
  hor_cor <- cor(hor, biomasa_matorral_df2[-samp,2], method="spearman")
  hor_rmse <- RMSE(hor, biomasa_matorral_df2[-samp,2])
  hor_nrmse <- nrmse(hor, biomasa_matorral_df2[-samp,2], norm="maxmin")
  # store results
  res_mat_vec[i,] <- c(hor_cor, hor_rmse, hor_nrmse)
  
  print(i)
}

head(res_mat_vec)

# save results to disc
setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
save(res_mat_vec, file="res_iter_perf_mat.RData")


## repeat for other vegetation types

####
#### pradera
####


setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_pr, file = "vsurf_prad.RData")
load("vsurf_prad.RData")

biomasa_prad_df <- prad_df[,2:217]

cor(biomasa_prad_df[,2], biomasa_prad_df[,vrfm_pr$varselect.pred+2], method="spearman")



png(filename = "pradera_pairs.png", width=1200, height=1200, res=300)
pairs(biomasa_prad_df[,c(2,(vrfm_pr$varselect.pred+2))])
dev.off()

    

res_prad_vec <- data.frame(matrix(nrow=100, ncol=3))
set.seed(25)

for (i in 1:100){
  
  # create random sample of the field data (80%)
  samp_prad <- sample(seq(1,nrow(biomasa_prad_df),1), round(nrow(biomasa_prad_df)*0.8))
  # train model based on the 80% field data
  rfm_it_prad <- randomForest(biomasa_prad_df[samp_prad,vrfm_pr$varselect.pred+2], biomasa_prad_df[samp_prad,2], ntree=500, importance = T)
  # predict model to the whole study area

  hor_prad <- predict(rfm_it_prad, biomasa_prad_df[-samp_prad,vrfm_pr$varselect.pred+2])
  # calculate correlation for hold out sample
  hor_prad_cor <- cor(hor_prad, biomasa_prad_df[-samp_prad,2], method="spearman")
  hor_prad_rmse <- RMSE(hor_prad, biomasa_prad_df[-samp_prad,2])
  hor_prad_nrmse <- nrmse(hor_prad, biomasa_prad_df[-samp_prad,2], norm="maxmin")
  
  res_prad_vec[i,] <- c(hor_prad_cor, hor_prad_rmse, hor_prad_nrmse)
  
  print(i)
}

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
save(res_prad_vec, file="res_iter_perf_prad.RData")


####
#### bosque nativo
####


setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_bn, file = "vsurf_bn.RData")
load("vsurf_bn.RData")

biomasa_bn_df <- bn_df[,2:217]

cor(biomasa_bn_df[,vrfm_bn$varselect.pred+2], biomasa_bn_df[,2], method="spearman")


png(filename = "bn_pairs.png", width=1800, height=1800, res=300)
pairs(biomasa_bn_df[,c(2,(vrfm_bn$varselect.pred+2))]) 
dev.off()

res_bn_vec <- data.frame(matrix(nrow=100, ncol=3))
set.seed(25)

for (i in 1:100){
  
  # create random sample of the field data (80%)
  samp_bn <- sample(seq(1,nrow(biomasa_bn_df),1), round(nrow(biomasa_bn_df)*0.8))
  # train model based on the 80% field data
  rfm_it_bn <- randomForest(biomasa_bn_df[samp_bn,vrfm_bn$varselect.pred+2], biomasa_bn_df[samp_bn,2], ntree=500, importance = T)

  # predict model to hold out sample
  hor_bn <- predict(rfm_it_bn, biomasa_bn_df[-samp_bn,vrfm_bn$varselect.pred+2])
  # calculate correlation for hold out sample
  hor_bn_cor <- cor(hor_bn, biomasa_bn_df[-samp_bn,2], method="spearman")
  hor_bn_rmse <- RMSE(hor_bn, biomasa_bn_df[-samp_bn,2])
  hor_bn_nrmse <- nrmse(hor_bn, biomasa_bn_df[-samp_bn,2], norm="maxmin")
  
  res_bn_vec[i,] <- c(hor_bn_cor, hor_bn_rmse, hor_bn_nrmse)
  
  print(i)
  
}

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
save(res_bn_vec, file="res_iter_perf_bn.RData")


####
#### pino
####

biomasa_PINO_df <- pin_df[,2:217]


setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_pin, file = "vsurf_pin.RData")
load("vsurf_pin.RData")

cor(biomasa_PINO_df[,vrfm_pin$varselect.pred+2], biomasa_PINO_df[,2], method="spearman")

png(filename = "pino_pairs.png", width=1200, height=1200, res=300)
pairs(biomasa_PINO_df[,c(2,(vrfm_pin$varselect.pred+2))]) 
dev.off()


res_pin_vec <- data.frame(matrix(nrow=100, ncol=3))
set.seed(25)

for (i in 1:100){

  # create random sample of the field data (80%)
  samp_pin <- sample(seq(1,nrow(biomasa_PINO_df),1), round(nrow(biomasa_PINO_df)*0.8))
  # train model based on the 80% field data
  rfm_it_pin <- randomForest(biomasa_PINO_df[samp_pin,vrfm_pin$varselect.pred+2], biomasa_PINO_df[samp_pin,2], ntree=500, importance = T)

  # predict model to hold out sample
  hor_pin <- predict(rfm_it_pin, biomasa_PINO_df[-samp_pin,vrfm_pin$varselect.pred+2])
  # calculate correlation for hold out sample
  hor_pin_cor <- cor(hor_pin, biomasa_PINO_df[-samp_pin,2], method="spearman")
  hor_pin_rmse <- RMSE(hor_pin, biomasa_PINO_df[-samp_pin,2])
  hor_pin_nrmse <- nrmse(hor_pin, biomasa_PINO_df[-samp_pin,2], norm="maxmin")
  
  res_pin_vec[i,] <- c(hor_pin_cor, hor_pin_rmse, hor_pin_nrmse)
  
  print(i)
  
}

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
save(res_pin_vec, file="res_iter_perf_pin.RData")
