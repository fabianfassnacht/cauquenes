## R-Script - merging biomass maps using the land cover data 
## author: Fabian Fassnacht 
## mail: fabianewaldfassnacht@gmail.com
## Manuscript: 
## last changes: 05.04.2020
##

# load package
require(raster)

# jump to folder containing boimass maps
# of the four vegetation types and load maps

setwd("/home/fabian/Fondecyt/5_outputs/5_maps")

map_bn <- stack("biomass_map_bn.tif")
map_pin <- stack("biomass_map_pine.tif") 
map_mat <-  stack("biomass_map_mat.tif")
map_prad <- stack("biomass_map_prad.tif")


# load the land-cover classification map
setwd("/home/fabian/Fondecyt/6_landcover/andres")
fourcl <- stack("LandCover_rf_2018_32718_crop.tif")

# resample biomass maps to match
# spatial resolution of land cover map
map_bn1 <- resample(map_bn, fourcl)
map_prad1 <- resample(map_prad, fourcl)
map_pin1 <- resample(map_pin, fourcl)
map_mat1 <- resample(map_prad, fourcl)

# convert rasters to dataframes
m_bn_v <- values(map_bn1)
m_pin_v <- values(map_pin1)
m_mat_v <- values(map_mat1)
m_prad_v <- values(map_prad1)

bm_df <- data.frame(m_bn_v, m_mat_v,m_pin_v, m_prad_v)

# convert landcover raster to vector
fcl_v <- values(fourcl) 

# fill up NA values with 0
fcl_v[is.na(fcl_v)] <- 0

# overview of the classes in the land-cover file
# 1 = water
# 2 = sand
# 3 = native forest
# 4 = agricultural fields 
# 5 = Eucalyptus
# 6 = wetlands
# 7 = shrublands
# 8 = pine plantation
# 9 = grassland
# 10 = soil
# 11 = urban area
# 12 = dead vegetation

# copy vector to have the same dimensions for storing results
res_v <- m_bn_v

# start the merging
for (i in 1:length(res_v)) {
  
   # if pixel of landcover map is one of the non relevant classes assign 0	  
  if (fcl_v[i] %in% c(0,1,2,4,5,6,10,11,12)){
    
    res_v[i] <- 0
    
    # if pixel of land-cover is native forest, assign native forest biomass
    } else if (fcl_v[i] == 3) {
      
      res_v[i] <- bm_df[i,1]
      
    # if pixel of land-cover is shrubland, assign shrublandt biomass  
    } else if (fcl_v[i] == 7) {
      
      res_v[i] <- bm_df[i,2]
    
    # if pixel of land-cover is pine forest, assign pine forest biomass
    } else if (fcl_v[i] == 8) {
      
      res_v[i] <- bm_df[i,3]
    
    # if pixel of land-cover is grassland, assign grassland  coefficient of variation
    } else if (fcl_v[i] == 9) {
      
      res_v[i] <- bm_df[i,4]
      
    } else {
      
      print("this cannot be")
      
    }
  
  if (i %in% seq(1,length(res_v),10000)){
    print(i)
  }
  
}

# copy raster file
res_raster <- fourcl

# overwrite raster file values with final results
values(res_raster) <- res_v

# store raster file with final results
writeRaster(res_raster, filename = "final_bm_map_luc.tif", format="GTiff")
