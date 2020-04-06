## R-Script - extracting iterative validation results
## author: Fabian Fassnacht 
## mail: fabianewaldfassnacht@gmail.com
## Manuscript: Using Multi-Sensor Data to Derive a Landscape-Level Biomass Map Covering Multiple Vegetation Types
## last changes: 05.04.2020
##

# load packages
require(matrixStats)
require(raster)

# change to folder with outputs of the modeling work-flow
setwd("/home/fabian/Fondecyt/5_outputs/5_maps/iterative_results")

#######################
## 1. correlation/rmse values
#######################

#######################
### native forests
#######################

# get all output files
bn <- list.files(pattern="results_iter_bn_cor_")

# create empty list to store results
bn_cor <- list()

# iterate through files and save correlation and rmse metrics
# in the list
for (i in 1:10){
  
  load(bn[i])
  bn_cor[[i]] <- data.frame(do.call(rbind, results_bn_cor))
  
  }

# merge all data and save to file
bn_end <- do.call(rbind, bn_cor)
save(bn_end, file="bn_iter_cor_rmse.RData")

## process is repated for the other land cover types

### shrublands
mat <- list.files(pattern="results_iter_mat_cor_")
mat_cor <- list()
for (i in 1:10){
  
  load(mat[i])
  mat_cor[[i]] <- data.frame(do.call(rbind, results_cor))
  
}

mat_end <- do.call(rbind, mat_cor)
save(mat_end, file="mat_iter_cor_rmse.RData")

#######################
### grasslands
#######################

prad <- list.files(pattern="results_iter_prad_cor_")
prad_cor <- list()
for (i in 1:10){
  
  load(prad[i])
  prad_cor[[i]] <- data.frame(do.call(rbind, results_prad_cor))
  
}

prad_end <- do.call(rbind, prad_cor)
save(prad_end, file="prad_iter_cor_rmse.RData")

#######################
### pine plantation
#######################

pin <- list.files(pattern="results_iter_pin_cor")
pin_cor <- list()
for (i in 1:10){
  
  load(pin[i])
  pin_cor[[i]] <- data.frame(do.call(rbind, results_pin_cor))
  
}

pin_end <- do.call(rbind, pin_cor)
save(pin_end, file="pin_iter_cor_rmse.RData")


#######################
## 2. maps
#######################


#######################
## maps pine
#######################

# get list of files containing maps in vector format
pinm <- list.files(pattern="results_iter_pin_vec")


# as data too big for the memory - process in two parts
# part 1

big <- list()

for (i in 1:10) {
  
  # load file
  load(pinm[i])
  print(paste0("loaded file ", i))
  
  # convert to dataframe
  ten_maps <- do.call(data.frame, results_pin_vec)
  
  # take first half of the data
  ten_maps2 <- ten_maps[1:(nrow(ten_maps)/2),]
  
  # remove file to free memory
  rm(ten_maps)
  
  # save data to list
  big[[i]] <- ten_maps2
  
  # remove file to free memory
  rm(ten_maps2)
  
  }  

# merge all data together
big_p1 <- do.call(cbind, big)  

# calculate required metrics
big_p1_sd <- rowSds(as.matrix(big_p1))
big_p1_mean <- rowMeans(as.matrix(big_p1))

# remove files to free memory
rm(big_p1)
rm(big)

# run garbage collect to free memory
gc()
gc()


## repeat the same with the second part of the data

big2 <- list()

# part 2

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_pin_vec)
  ten_maps2 <- ten_maps[(nrow(ten_maps)/2+1):nrow(ten_maps),]
  rm(ten_maps)
  big2[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p2 <- do.call(cbind, big2)  
big_p2_sd <- rowSds(as.matrix(big_p2))
big_p2_mean <- rowMeans(as.matrix(big_p2))

rm(big_p2)
rm(big2)

# merge the two parts

sd_fin <- c(big_p1_sd, big_p2_sd)
mean_fin <- c(big_p1_mean, big_p2_mean)

# calculate coefficient of variation
ceff_var_fin <- sd_fin/mean_fin

# export to raster
dummy_sd <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_pine.tif")
dummy_mean <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_pine.tif")
dummy_ceff_var <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_pine.tif")

# overwrite dummy raster values with final results
values(dummy_sd) <- sd_fin
values(dummy_mean) <- mean_fin
values(dummy_ceff_var) <- ceff_var_fin

# store raster files to disc
writeRaster(dummy_sd, filename = "SD_biom_pine_100ter.tif", format="GTiff")
writeRaster(dummy_mean, filename = "MEAN_biom_pine_100ter.tif", format="GTiff")
writeRaster(dummy_ceff_var, filename = "CEFF_VAR_biom_pine_100ter.tif", format="GTiff")


## repeat process for other vegetation types


#######################
## maps bosque nativo
#######################

pinm <- list.files(pattern="results_iter_bn_vec")


# as data too big for the memory - process in two parts
# part 1

big <- list()

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_bn_vec)
  ten_maps2 <- ten_maps[1:(nrow(ten_maps)/2),]
  rm(ten_maps)
  big[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p1 <- do.call(cbind, big)  
big_p1_sd <- rowSds(as.matrix(big_p1))
big_p1_mean <- rowMeans(as.matrix(big_p1))

rm(big_p1)
rm(big)
gc()
gc()

big2 <- list()

# part 2

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_bn_vec)
  ten_maps2 <- ten_maps[(nrow(ten_maps)/2+1):nrow(ten_maps),]
  rm(ten_maps)
  big2[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p2 <- do.call(cbind, big2)  
big_p2_sd <- rowSds(as.matrix(big_p2))
big_p2_mean <- rowMeans(as.matrix(big_p2))

rm(big_p2)
rm(big2)

# merge parts

sd_fin <- c(big_p1_sd, big_p2_sd)
mean_fin <- c(big_p1_mean, big_p2_mean)
ceff_var_fin <- sd_fin/mean_fin

# export to raster
dummy_sd <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_mean <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_ceff_var <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")

values(dummy_sd) <- sd_fin
values(dummy_mean) <- mean_fin
values(dummy_ceff_var) <- ceff_var_fin

writeRaster(dummy_sd, filename = "SD_biom_bn_100ter.tif", format="GTiff")
writeRaster(dummy_mean, filename = "MEAN_biom_bn_100ter.tif", format="GTiff")
writeRaster(dummy_ceff_var, filename = "CEFF_VAR_biom_bn_100ter.tif", format="GTiff")


#######################
## maps praderas
#######################

pinm <- list.files(pattern="results_iter_prad_vec")


# as data too big for the memory - process in two parts
# part 1

big <- list()

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_prad_vec)
  ten_maps2 <- ten_maps[1:(nrow(ten_maps)/2),]
  rm(ten_maps)
  big[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p1 <- do.call(cbind, big)  
big_p1_sd <- rowSds(as.matrix(big_p1))
big_p1_mean <- rowMeans(as.matrix(big_p1))

rm(big_p1)
rm(big)
gc()
gc()

big2 <- list()

# part 2

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_prad_vec)
  ten_maps2 <- ten_maps[(nrow(ten_maps)/2+1):nrow(ten_maps),]
  rm(ten_maps)
  big2[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p2 <- do.call(cbind, big2)  
big_p2_sd <- rowSds(as.matrix(big_p2))
big_p2_mean <- rowMeans(as.matrix(big_p2))

rm(big_p2)
rm(big2)

# merge parts

sd_fin <- c(big_p1_sd, big_p2_sd)
mean_fin <- c(big_p1_mean, big_p2_mean)
ceff_var_fin <- sd_fin/mean_fin

# export to raster
dummy_sd <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_mean <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_ceff_var <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")

values(dummy_sd) <- sd_fin
values(dummy_mean) <- mean_fin
values(dummy_ceff_var) <- ceff_var_fin

writeRaster(dummy_sd, filename = "SD_biom_prad_100ter.tif", format="GTiff")
writeRaster(dummy_mean, filename = "MEAN_biom_prad_100ter.tif", format="GTiff")
writeRaster(dummy_ceff_var, filename = "CEFF_VAR_biom_prad_100ter.tif", format="GTiff")


#######################
## maps matorral
#######################

pinm <- list.files(pattern="results_iter_mat_vec")


# as data too big for the memory - process in two parts
# part 1

big <- list()

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_vec)
  ten_maps2 <- ten_maps[1:(nrow(ten_maps)/2),]
  rm(ten_maps)
  big[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p1 <- do.call(cbind, big)  
big_p1_sd <- rowSds(as.matrix(big_p1))
big_p1_mean <- rowMeans(as.matrix(big_p1))

rm(big_p1)
rm(big)
gc()
gc()

big2 <- list()

# part 2

for (i in 1:10) {
  
  load(pinm[i])
  print(paste0("loaded file ", i))
  ten_maps <- do.call(data.frame, results_vec)
  ten_maps2 <- ten_maps[(nrow(ten_maps)/2+1):nrow(ten_maps),]
  rm(ten_maps)
  big2[[i]] <- ten_maps2
  rm(ten_maps2)
  
}  

big_p2 <- do.call(cbind, big2)  
big_p2_sd <- rowSds(as.matrix(big_p2))
big_p2_mean <- rowMeans(as.matrix(big_p2))

rm(big_p2)
rm(big2)

# merge parts

sd_fin <- c(big_p1_sd, big_p2_sd)
mean_fin <- c(big_p1_mean, big_p2_mean)
ceff_var_fin <- sd_fin/mean_fin

# export to raster
dummy_sd <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_mean <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")
dummy_ceff_var <- stack("/home/fabian/Fondecyt/5_outputs/5_maps/biomass_map_bn.tif")

values(dummy_sd) <- sd_fin
values(dummy_mean) <- mean_fin
values(dummy_ceff_var) <- ceff_var_fin

writeRaster(dummy_sd, filename = "SD_biom_mat_100ter.tif", format="GTiff", overwrite=T)
writeRaster(dummy_mean, filename = "MEAN_biom_mat_100ter.tif", format="GTiff", overwrite=T)
writeRaster(dummy_ceff_var, filename = "CEFF_VAR_biom_mat_100ter.tif", format="GTiff", overwrite=T)
