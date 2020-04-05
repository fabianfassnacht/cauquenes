## R-Script - calculate texture metrics
## author: Andres Ceballos / Fabian Fassnacht
## mail: fabianewaldfassnacht@gmail.com
## Manuscript: 
## last changes: 05.04.2020
##


# load packages
require(glcm)
require(rgdal)
require(raster)

# load glcm function
source("/home/fabian/Fondecyt/1_R_code/codes_final/Funcion_GLCM3x3.R")

# set output directory
out2 = '/home/fabian/Fondecyt/2_remote_sensing_data/texture'

# Define metrics to be calculated
tipo <- c("contrast","entropy","mean")

# jump into parent folder
setwd("/home/fabian/Fondecyt")

# load all variables for which metrics shall be computed

# ---- Sentinel-2 Bands ----

B2_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B02_ver.tif"))
B3_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B03_ver.tif"))
B4_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B04_ver.tif"))
B5_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B05_ver.tif"))
B6_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B06_ver.tif"))
B7_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B07_ver.tif"))
B8a_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B08a_ver.tif"))
B11_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B11_ver.tif"))
B12_ver = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B12_ver.tif"))

B2_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B02_inv.tif"))
B3_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B03_inv.tif"))
B4_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B04_inv.tif"))
B5_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B05_inv.tif"))
B6_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B06_inv.tif"))
B7_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B07_inv.tif"))
B8a_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B08a_inv.tif"))
B11_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B11_inv.tif"))
B12_inv = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/B12_inv.tif"))

# ---- S2-based Biophysical operator ----

LAI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/LAI_ver.tif")) # Leaf area index 2019 01 29
Cab_ver = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/Cab_ver.tif")) # Chlorophyll content in the leaf
Cwc_ver = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/Cwc_ver.tif")) # Canopy water content
FPAR_ver = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/FPAR_ver.tif")) # FPAR
FVC_ver = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/FVC_ver.tif")) # FCOVER

LAI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/LAI_inv.tif")) # Leaf area index 2019 07 23
Cab_inv = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/Cab_inv.tif"))
Cwc_inv = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/Cwc_inv.tif"))
FPAR_inv = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/FPAR_inv.tif"))
FVC_inv = raster(paste0(getwd(), "/2_remote_sensing_data/biophysical_operator/FVC_inv.tif"))


# ---- S2-based Vegetation indices ----

GNDVI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/GNDVI_ver.tif"))
IRECI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/IRECI_ver.tif"))
NDI45_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/NDI45_ver.tif"))
NDVI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/NDVI_ver.tif"))
SAVI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/SAVI_ver.tif"))
TNDVI_ver = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/TNDVI_ver.tif"))

GNDVI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/GNDVI_inv.tif"))
IRECI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/IRECI_inv.tif"))
NDI45_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/NDI45_inv.tif"))
NDVI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/NDVI_inv.tif"))
SAVI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/SAVI_inv.tif"))
TNDVI_inv = raster(paste0(getwd(), "/2_remote_sensing_data/IVs/TNDVI_inv.tif"))


# ---- Topography metrics ----

slope = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/slope.tif"))
aspect = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/aspect.tif"))
cnbl = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/cnbl.tif")) # channel network base level
cnd = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/cnd.tif")) # channel network distance to stream
CI = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/CI.tif")) # convergence index
LS_factor = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/LS_factor.tif")) # LS factor
PlanCurv = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/PlanCurvature.tif")) # plan curvature
ProfCurv = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/ProfCurvature.tif")) # profile curvature
TWI = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/TWI.tif")) # topographic wetness index

# ---- CHM metrics ----

MDC = raster(paste0(getwd(), "/2_remote_sensing_data/dem/MDC.tif")) # modelo de copas a 10 m 
DEM = raster(paste0(getwd(), "/2_remote_sensing_data/dem/DEM_5m.tif")) # DEM Arauco a 5 m 
TX = raster(paste0(getwd(), "/2_remote_sensing_data/dem/nDSM_tdx_cor.tif"))

# call function to caclulate glcm metrics

GLCM3x3(stack = stack(B2_ver,B3_ver,B4_ver,B5_ver,B6_ver,B7_ver,B8a_ver,B11_ver,B12_ver,B2_inv,B3_inv,B4_inv,B5_inv,B6_inv,B7_inv,B8a_inv,B11_inv,B12_inv) ,path = out2,stats = tipo) 
GLCM3x3(stack = stack(LAI_ver,Cab_ver,Cwc_ver,FPAR_ver,FVC_ver,LAI_inv,Cab_inv,Cwc_inv,FPAR_inv,FVC_inv) ,path = out2,stats = tipo)
GLCM3x3(stack = stack(GNDVI_ver,IRECI_ver,NDI45_ver,NDVI_ver,SAVI_ver,TNDVI_ver,GNDVI_inv,IRECI_inv,NDI45_inv,NDVI_inv,SAVI_inv,TNDVI_inv) ,path = out2,stats = tipo)
GLCM3x3(stack = stack(slope, aspect, cnbl, cnd, CI, LS_factor, PlanCurv, ProfCurv, TWI) ,path = out2,stats = tipo)
GLCM3x3(stack = stack(MDC) ,path = out2,stats = tipo)
GLCM3x3(stack = stack(DEM) ,path = out2,stats = tipo)
GLCM3x3(stack = stack(TX) ,path = out2,stats = tipo)

