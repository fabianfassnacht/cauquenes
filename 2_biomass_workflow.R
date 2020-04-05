## R-Script - biomass modelling work-flow
## author: Fabian Fassnacht / 
## mail: fabianewaldfassnacht@gmail.com
## Manuscript: 
## last changes: 05.04.2020
##



# load packages
library(raster)
library(rgdal)
require(randomForest)
require(VSURF)
require(MLmetrics)
require(matrixStats)
require(hydroGOF)

# set working directory
setwd("/home/fabian/Fondecyt")

# load reference data
limits = readOGR(paste0(getwd(),"/3_shapes/Cauquenes_limits.shp")) # boundaries cuenca
biomasa_BN = readOGR(paste0(getwd(),"/3_shapes/Biomasa_BN_actualizada.shp")) # datos biomasa BN
biomasa_MAT = readOGR(paste0(getwd(),"/3_shapes/matorrales_corr.shp")) # datos biomasa matorral
biomasa_PINO = readOGR(paste0(getwd(),"/3_shapes/plantacion_forestal_cor.shp")) # datos biomasa plantaciones forestales
biomasa_PRAD <- readOGR(paste0(getwd(),"/3_shapes/s2_praderas_reference_cor.shp"))

# load raster data

# ---- elevation data ----

MDC = raster(paste0(getwd(), "/2_remote_sensing_data/dem/MDC.tif")) # modelo de copas a 10 m 
DEM = raster(paste0(getwd(), "/2_remote_sensing_data/dem/DEM_5m.tif")) # DEM Arauco a 5 m 
TX = raster(paste0(getwd(), "/2_remote_sensing_data/dem/nDSM_tdx_cor.tif"))

# ---- Bandas Sentinel 2 ----

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

# ---- S2-based Indices de vegetacion ----
  
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

NDVI_sd = raster(paste0(getwd(), "/2_remote_sensing_data/imgs_S2/S2_inv_comb.tif"))

# ---- Derivadas topograficas ----

slope = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/slope.tif"))
aspect = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/aspect.tif"))
cnbl = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/cnbl.tif")) # channel network base level
cnd = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/cnd.tif")) # channel network distance to stream
CI = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/CI.tif")) # convergence index
LS_factor = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/LS_factor.tif")) # LS factor
PlanCurv = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/PlanCurvature.tif")) # plan curvature
ProfCurv = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/ProfCurvature.tif")) # profile curvature
TWI = raster(paste0(getwd(), "/2_remote_sensing_data/terrain_analysis/TWI.tif")) # topographic wetness index


# ---- Texture variables ----

B02_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_dis.tif"))
B02_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_mea.tif"))
B02_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_var.tif"))
B02_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_dis.tif"))
B02_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_mea.tif"))
B02_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B02_inv_3x3_var.tif"))

B03_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_dis.tif"))
B03_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_mea.tif"))
B03_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_var.tif"))
B03_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_dis.tif"))
B03_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_mea.tif"))
B03_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B03_inv_3x3_var.tif"))

B04_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_dis.tif"))
B04_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_mea.tif"))
B04_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_var.tif"))
B04_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_dis.tif"))
B04_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_mea.tif"))
B04_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B04_inv_3x3_var.tif"))

B05_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_dis.tif"))
B05_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_mea.tif"))
B05_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_var.tif"))
B05_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_dis.tif"))
B05_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_mea.tif"))
B05_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B05_inv_3x3_var.tif"))

B06_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_dis.tif"))
B06_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_mea.tif"))
B06_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_var.tif"))
B06_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_dis.tif"))
B06_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_mea.tif"))
B06_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B06_inv_3x3_var.tif"))

B07_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_dis.tif"))
B07_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_mea.tif"))
B07_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_var.tif"))
B07_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_dis.tif"))
B07_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_mea.tif"))
B07_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B07_inv_3x3_var.tif"))

B08a_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_dis.tif"))
B08a_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_mea.tif"))
B08a_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_var.tif"))
B08a_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_dis.tif"))
B08a_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_mea.tif"))
B08a_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B08a_inv_3x3_var.tif"))

B11_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_dis.tif"))
B11_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_mea.tif"))
B11_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_var.tif"))
B11_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_dis.tif"))
B11_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_mea.tif"))
B11_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B11_inv_3x3_var.tif"))

B12_inv_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_dis.tif"))
B12_inv_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_mea.tif"))
B12_inv_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_var.tif"))
B12_ver_tex_3_dis = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_dis.tif"))
B12_ver_tex_3_mea = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_mea.tif"))
B12_ver_tex_3_var = stack(paste0(getwd(), "/2_remote_sensing_data/texture/B12_inv_3x3_var.tif"))

# texture biophysical indicators

LAI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_ver_3x3_dis.tif")) # Leaf area index 2019 01 29
LAI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_ver_3x3_mea.tif")) # Leaf area index 2019 01 29
LAI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_ver_3x3_var.tif")) # Leaf area index 2019 01 29

Cab_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_ver_3x3_dis.tif")) # Chlorophyll content in the leaf
Cab_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_ver_3x3_mea.tif")) # Chlorophyll content in the leaf
Cab_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_ver_3x3_var.tif")) # Chlorophyll content in the leaf

Cwc_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_ver_3x3_dis.tif")) # Canopy water content
Cwc_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_ver_3x3_mea.tif")) # Canopy water content
Cwc_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_ver_3x3_var.tif")) # Canopy water content

FPAR_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_ver_3x3_dis.tif")) # FPAR
FPAR_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_ver_3x3_mea.tif")) # FPAR
FPAR_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_ver_3x3_var.tif")) # FPAR

FVC_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_ver_3x3_dis.tif")) # FCOVER
FVC_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_ver_3x3_mea.tif")) # FCOVER
FVC_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_ver_3x3_var.tif")) # FCOVER


LAI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_inv_3x3_dis.tif")) # Leaf area index 2019 01 29
LAI_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_inv_3x3_mea.tif")) # Leaf area index 2019 01 29
LAI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LAI_inv_3x3_var.tif")) # Leaf area index 2019 01 29

Cab_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_inv_3x3_dis.tif")) # Chlorophyll content in the leaf
Cab_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_inv_3x3_mea.tif")) # Chlorophyll content in the leaf
Cab_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cab_inv_3x3_var.tif")) # Chlorophyll content in the leaf

Cwc_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_inv_3x3_dis.tif")) # Canopy water content
Cwc_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_inv_3x3_mea.tif")) # Canopy water content
Cwc_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/Cwc_inv_3x3_var.tif")) # Canopy water content

FPAR_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_inv_3x3_dis.tif")) # FPAR
FPAR_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_inv_3x3_mea.tif")) # FPAR
FPAR_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FPAR_inv_3x3_var.tif")) # FPAR

FVC_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_inv_3x3_dis.tif")) # FCOVER
FVC_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_inv_3x3_mea.tif")) # FCOVER
FVC_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/FVC_inv_3x3_var.tif")) # FCOVER

# texture VIs

GNDVI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_ver_3x3_dis.tif"))
GNDVI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_ver_3x3_mea.tif"))
GNDVI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_ver_3x3_var.tif"))

IRECI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_ver_3x3_dis.tif"))
IRECI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_ver_3x3_mea.tif"))
IRECI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_ver_3x3_var.tif"))

NDI45_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_ver_3x3_dis.tif"))
NDI45_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_ver_3x3_mea.tif"))
NDI45_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_ver_3x3_var.tif"))

NDVI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_ver_3x3_dis.tif"))
NDVI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_ver_3x3_mea.tif"))
NDVI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_ver_3x3_var.tif"))

SAVI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_ver_3x3_dis.tif"))
SAVI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_ver_3x3_mea.tif"))
SAVI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_ver_3x3_var.tif"))

TNDVI_ver_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_ver_3x3_dis.tif"))
TNDVI_ver_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_ver_3x3_mea.tif"))
TNDVI_ver_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_ver_3x3_var.tif"))



GNDVI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_inv_3x3_dis.tif"))
GNDVI_inv_tex_3_mea= raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_inv_3x3_mea.tif"))
GNDVI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/GNDVI_inv_3x3_var.tif"))

IRECI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_inv_3x3_dis.tif"))
IRECI_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_inv_3x3_mea.tif"))
IRECI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/IRECI_inv_3x3_var.tif"))

NDI45_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_inv_3x3_dis.tif"))
NDI45_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_inv_3x3_mea.tif"))
NDI45_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDI45_inv_3x3_var.tif"))

NDVI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_inv_3x3_dis.tif"))
NDVI_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_inv_3x3_mea.tif"))
NDVI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/NDVI_inv_3x3_var.tif"))

SAVI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_inv_3x3_dis.tif"))
SAVI_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_inv_3x3_mea.tif"))
SAVI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/SAVI_inv_3x3_var.tif"))

TNDVI_inv_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_inv_3x3_dis.tif"))
TNDVI_inv_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_inv_3x3_mea.tif"))
TNDVI_inv_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TNDVI_inv_3x3_var.tif"))


# texture topography

slope_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/slope_3x3_dis.tif"))
slope_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/slope_3x3_mea.tif"))
slope_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/slope_3x3_var.tif"))

aspect_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/aspect_3x3_dis.tif"))
aspect_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/aspect_3x3_mea.tif"))
aspect_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/aspect_3x3_var.tif"))

cnbl_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnbl_3x3_dis.tif")) # channel network base level
cnbl_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnbl_3x3_mea.tif")) # channel network base level
cnbl_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnbl_3x3_var.tif")) # channel network base level

cnd_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnd_3x3_dis.tif")) # channel network distance to stream
cnd_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnd_3x3_mea.tif")) # channel network distance to stream
cnd_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/cnd_3x3_var.tif")) # channel network distance to stream

CI_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/CI_3x3_dis.tif")) # convergence index
CI_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/CI_3x3_mea.tif")) # convergence index
CI_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/CI_3x3_var.tif")) # convergence index

LS_factor_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LS_factor_3x3_dis.tif")) # LS factor
LS_factor_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LS_factor_3x3_mea.tif")) # LS factor
LS_factor_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/LS_factor_3x3_var.tif")) # LS factor

PlanCurv_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/PlanCurvature_3x3_dis.tif")) # plan curvature
PlanCurv_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/PlanCurvature_3x3_mea.tif")) # plan curvature
PlanCurv_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/PlanCurvature_3x3_var.tif")) # plan curvature

ProfCurv_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/ProfCurvature_3x3_dis.tif")) # profile curvature
ProfCurv_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/ProfCurvature_3x3_mea.tif")) # profile curvature
ProfCurv_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/ProfCurvature_3x3_var.tif")) # profile curvature

TWI_tex_3_dis  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TWI_3x3_dis.tif")) # topographic wetness index
TWI_tex_3_mea  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TWI_3x3_mea.tif")) # topographic wetness index
TWI_tex_3_var  = raster(paste0(getwd(), "/2_remote_sensing_data/texture/TWI_3x3_var.tif")) # topographic wetness index

## texture canopy height models

MDC_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/MDC_3x3_dis.tif")) # modelo de copas a 10 m 
MDC_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/MDC_3x3_mea.tif")) # modelo de copas a 10 m 
MDC_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/MDC_3x3_var.tif")) # modelo de copas a 10 m 

DEM_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/DEM_5m_3x3_dis.tif")) # DEM Arauco a 5 m 
DEM_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/DEM_5m_3x3_mea.tif")) # DEM Arauco a 5 m 
DEM_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/DEM_5m_3x3_var.tif")) # DEM Arauco a 5 m 

TX_tex_3_dis = raster(paste0(getwd(), "/2_remote_sensing_data/texture/nDSM_tdx_cor_3x3_dis.tif"))
TX_tex_3_mea = raster(paste0(getwd(), "/2_remote_sensing_data/texture/nDSM_tdx_cor_3x3_mea.tif"))
TX_tex_3_var = raster(paste0(getwd(), "/2_remote_sensing_data/texture/nDSM_tdx_cor_3x3_var.tif"))


# ---- EXTRACT ----

setwd("/home/fabian/Fondecyt/5_outputs/1_dataframes")

# Grasslands 

biomasa_prad_df = data.frame(parcela = biomasa_PRAD$Nombre,
                           #GPS = biomasa_PRAD$height,
                           AGB_ton_ha = biomasa_PRAD$bio_t_ha,
                           MDC_m = extract(MDC, biomasa_PRAD),
                           DEM_m = extract(DEM, biomasa_PRAD),
                           TX = extract(TX, biomasa_PRAD),
                           B2_ver = extract(B2_ver, biomasa_PRAD),
                           B3_ver = extract(B3_ver, biomasa_PRAD),
                           B4_ver = extract(B4_ver, biomasa_PRAD),
                           B5_ver = extract(B5_ver, biomasa_PRAD),
                           B6_ver = extract(B6_ver, biomasa_PRAD),
                           B7_ver = extract(B7_ver, biomasa_PRAD),
                           B8a_ver = extract(B8a_ver, biomasa_PRAD),
                           B11_ver = extract(B11_ver, biomasa_PRAD),
                           B12_ver = extract(B12_ver, biomasa_PRAD),

                           LAI_ver = extract(LAI_ver, biomasa_PRAD),
                           Cab_ver = extract(Cab_ver, biomasa_PRAD),
                           Cwc_ver = extract(Cwc_ver, biomasa_PRAD),
                           FPAR_ver = extract(FPAR_ver, biomasa_PRAD),
                           FVC_ver = extract(FVC_ver, biomasa_PRAD),
                           GNDVI_ver = extract(GNDVI_ver, biomasa_PRAD),
                           IRECI_ver = extract(IRECI_ver, biomasa_PRAD),
                           NDI45_ver = extract(NDI45_ver, biomasa_PRAD),
                           NDVI_ver = extract(NDVI_ver, biomasa_PRAD),
                           SAVI_ver = extract(SAVI_ver, biomasa_PRAD),
                           TNDVI_ver = extract(TNDVI_ver, biomasa_PRAD),
                           B2_inv = extract(B2_inv, biomasa_PRAD),
                           B3_inv = extract(B3_inv, biomasa_PRAD),
                           B4_inv = extract(B4_inv, biomasa_PRAD),
                           B5_inv = extract(B5_inv, biomasa_PRAD),
                           B6_inv = extract(B6_inv, biomasa_PRAD),
                           B7_inv = extract(B7_inv, biomasa_PRAD),
                           B8a_inv = extract(B8a_inv, biomasa_PRAD),
                           B11_inv = extract(B11_inv, biomasa_PRAD),
                           B12_inv = extract(B12_inv, biomasa_PRAD),
                           LAI_inv = extract(LAI_inv, biomasa_PRAD),
                           Cab_inv = extract(Cab_inv, biomasa_PRAD),
                           Cwc_inv = extract(Cwc_inv, biomasa_PRAD),
                           FPAR_inv = extract(FPAR_inv, biomasa_PRAD),
                           FVC_inv = extract(FVC_inv, biomasa_PRAD),
                           GNDVI_inv = extract(GNDVI_inv, biomasa_PRAD),
                           IRECI_inv = extract(IRECI_inv, biomasa_PRAD),
                           NDI45_inv = extract(NDI45_inv, biomasa_PRAD),
                           NDVI_inv = extract(NDVI_inv, biomasa_PRAD),
                           SAVI_inv = extract(SAVI_inv, biomasa_PRAD),
                           TNDVI_inv = extract(TNDVI_inv, biomasa_PRAD),
                           slope = extract(slope, biomasa_PRAD),
                           aspect = extract(aspect, biomasa_PRAD),
                           cnbl = extract(cnbl, biomasa_PRAD),
                           cnd = extract(cnd, biomasa_PRAD),
                           CI = extract(CI, biomasa_PRAD),
                           LS_factor = extract(LS_factor, biomasa_PRAD),
                           PlanCurv = extract(PlanCurv, biomasa_PRAD),
                           ProfCurv = extract(ProfCurv, biomasa_PRAD),
                           TWI = extract(TWI, biomasa_PRAD),
                           
                           B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_PRAD),
                           B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_PRAD),
                           B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_PRAD),
                           B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_PRAD),
                           B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_PRAD),
                           B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_PRAD),
                           
                           B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_PRAD),
                           B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_PRAD),
                           B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_PRAD),
                           B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_PRAD),
                           B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_PRAD),
                           B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_PRAD),
                           
                           B03_i_t_3_dis = extract(B03_inv_tex_3_dis, biomasa_PRAD),
                           B03_i_t_3_mea = extract(B03_inv_tex_3_mea, biomasa_PRAD),
                           B03_i_t_3_var = extract(B03_inv_tex_3_var, biomasa_PRAD),
                           B03_v_t_3_dis = extract(B03_ver_tex_3_dis, biomasa_PRAD),
                           B03_v_t_3_mea = extract(B03_ver_tex_3_mea, biomasa_PRAD),
                           B03_v_t_3_var = extract(B03_ver_tex_3_var, biomasa_PRAD),
                           
                           B04_i_t_3_dis = extract(B04_inv_tex_3_dis, biomasa_PRAD),
                           B04_i_t_3_mea = extract(B04_inv_tex_3_mea, biomasa_PRAD),
                           B04_i_t_3_var = extract(B04_inv_tex_3_var, biomasa_PRAD),
                           B04_v_t_3_dis = extract(B04_ver_tex_3_dis, biomasa_PRAD),
                           B04_v_t_3_mea = extract(B04_ver_tex_3_mea, biomasa_PRAD),
                           B04_v_t_3_var = extract(B04_ver_tex_3_var, biomasa_PRAD),
                           
                           B05_i_t_3_dis = extract(B05_inv_tex_3_dis, biomasa_PRAD),
                           B05_i_t_3_mea = extract(B05_inv_tex_3_mea, biomasa_PRAD),
                           B05_i_t_3_var = extract(B05_inv_tex_3_var, biomasa_PRAD),
                           B05_v_t_3_dis = extract(B05_ver_tex_3_dis, biomasa_PRAD),
                           B05_v_t_3_mea = extract(B05_ver_tex_3_mea, biomasa_PRAD),
                           B05_v_t_3_var = extract(B05_ver_tex_3_var, biomasa_PRAD),
                           
                           B06_i_t_3_dis = extract(B06_inv_tex_3_dis, biomasa_PRAD),
                           B06_i_t_3_mea = extract(B06_inv_tex_3_mea, biomasa_PRAD),
                           B06_i_t_3_var = extract(B06_inv_tex_3_var, biomasa_PRAD),
                           B06_v_t_3_dis = extract(B06_ver_tex_3_dis, biomasa_PRAD),
                           B06_v_t_3_mea = extract(B06_ver_tex_3_mea, biomasa_PRAD),
                           B06_v_t_3_var = extract(B06_ver_tex_3_var, biomasa_PRAD),
                           
                           B07_i_t_3_dis = extract(B07_inv_tex_3_dis, biomasa_PRAD),
                           B07_i_t_3_mea = extract(B07_inv_tex_3_mea, biomasa_PRAD),
                           B07_i_t_3_var = extract(B07_inv_tex_3_var, biomasa_PRAD),
                           B07_v_t_3_dis = extract(B07_ver_tex_3_dis, biomasa_PRAD),
                           B07_v_t_3_mea = extract(B07_ver_tex_3_mea, biomasa_PRAD),
                           B07_v_t_3_var = extract(B07_ver_tex_3_var, biomasa_PRAD),
                           
                           B08a_i_t_3_dis = extract(B08a_inv_tex_3_dis, biomasa_PRAD),
                           B08a_i_t_3_mea = extract(B08a_inv_tex_3_mea, biomasa_PRAD),
                           B08a_i_t_3_var = extract(B08a_inv_tex_3_var, biomasa_PRAD),
                           B08a_v_t_3_dis = extract(B08a_ver_tex_3_dis, biomasa_PRAD),
                           B08a_v_t_3_mea = extract(B08a_ver_tex_3_mea, biomasa_PRAD),
                           B08a_v_t_3_var = extract(B08a_ver_tex_3_var, biomasa_PRAD),
                           
                           B11_i_t_3_dis = extract(B11_inv_tex_3_dis, biomasa_PRAD),
                           B11_i_t_3_mea = extract(B11_inv_tex_3_mea, biomasa_PRAD),
                           B11_i_t_3_var = extract(B11_inv_tex_3_var, biomasa_PRAD),
                           B11_v_t_3_dis = extract(B11_ver_tex_3_dis, biomasa_PRAD),
                           B11_v_t_3_mea = extract(B11_ver_tex_3_mea, biomasa_PRAD),
                           B11_v_t_3_var = extract(B11_ver_tex_3_var, biomasa_PRAD),
                           
                           B12_i_t_3_dis = extract(B12_inv_tex_3_dis, biomasa_PRAD),
                           B12_i_t_3_mea = extract(B12_inv_tex_3_mea, biomasa_PRAD),
                           B12_i_t_3_var = extract(B12_inv_tex_3_var, biomasa_PRAD),
                           B12_v_t_3_dis = extract(B12_ver_tex_3_dis, biomasa_PRAD),
                           B12_v_t_3_mea = extract(B12_ver_tex_3_mea, biomasa_PRAD),
                           B12_v_t_3_var = extract(B12_ver_tex_3_var, biomasa_PRAD),
                           
                           MDC_t_3_dis = extract(MDC_tex_3_dis, biomasa_PRAD),
                           MDC_t_3_mea = extract(MDC_tex_3_mea, biomasa_PRAD),
                           MDC_t_3_var = extract(MDC_tex_3_var, biomasa_PRAD),
                           
                           DEM_t_3_dis = extract(DEM_tex_3_dis, biomasa_PRAD),
                           DEM_t_3_mea = extract(DEM_tex_3_mea, biomasa_PRAD),
                           DEM_t_3_var = extract(DEM_tex_3_var, biomasa_PRAD),
                           
                           TX_t_3_dis = extract(TX_tex_3_dis, biomasa_PRAD),
                           TX_t_3_mea = extract(TX_tex_3_mea, biomasa_PRAD),
                           TX_t_3_var = extract(TX_tex_3_var, biomasa_PRAD),
                           
                           # biopyhsical
                           
                           LAI_ver_t_3_dis = extract(LAI_ver_tex_3_dis, biomasa_PRAD),
                           LAI_ver_t_3_mea = extract(LAI_ver_tex_3_mea, biomasa_PRAD),
                           LAI_ver_t_3_var = extract(LAI_ver_tex_3_var, biomasa_PRAD),
                           
                           Cab_ver_t_3_dis = extract(Cab_ver_tex_3_dis, biomasa_PRAD),
                           Cab_ver_t_3_mea = extract(Cab_ver_tex_3_mea, biomasa_PRAD),
                           Cab_ver_t_3_var = extract(Cab_ver_tex_3_var, biomasa_PRAD),
                           
                           Cwc_ver_t_3_dis = extract(Cwc_ver_tex_3_dis, biomasa_PRAD),
                           Cwc_ver_t_3_mea = extract(Cwc_ver_tex_3_mea, biomasa_PRAD),
                           Cwc_ver_t_3_var = extract(Cwc_ver_tex_3_var, biomasa_PRAD),
                           
                           FPAR_ver_t_3_dis = extract(FPAR_ver_tex_3_dis, biomasa_PRAD),
                           FPAR_ver_t_3_mea = extract(FPAR_ver_tex_3_mea, biomasa_PRAD),
                           FPAR_ver_t_3_var = extract(FPAR_ver_tex_3_var, biomasa_PRAD),
                           
                           FVC_ver_t_3_dis = extract(FVC_ver_tex_3_dis, biomasa_PRAD),
                           FVC_ver_t_3_mea = extract(FVC_ver_tex_3_mea, biomasa_PRAD),
                           FVC_ver_t_3_var = extract(FVC_ver_tex_3_var, biomasa_PRAD),
                           
                           
                           LAI_inv_t_3_dis = extract(LAI_inv_tex_3_dis, biomasa_PRAD),
                           LAI_inv_t_3_mea = extract(LAI_inv_tex_3_mea, biomasa_PRAD),
                           LAI_inv_t_3_var = extract(LAI_inv_tex_3_var, biomasa_PRAD),
                           
                           Cab_inv_t_3_dis = extract(Cab_inv_tex_3_dis, biomasa_PRAD),
                           Cab_inv_t_3_mea = extract(Cab_inv_tex_3_mea, biomasa_PRAD),
                           Cab_inv_t_3_var = extract(Cab_inv_tex_3_var, biomasa_PRAD),
                           
                           Cwc_inv_t_3_dis = extract(Cwc_inv_tex_3_dis, biomasa_PRAD),
                           Cwc_inv_t_3_mea = extract(Cwc_inv_tex_3_mea, biomasa_PRAD),
                           Cwc_inv_t_3_var = extract(Cwc_inv_tex_3_var, biomasa_PRAD),
                           
                           FPAR_inv_t_3_dis = extract(FPAR_inv_tex_3_dis, biomasa_PRAD),
                           FPAR_inv_t_3_mea = extract(FPAR_inv_tex_3_mea, biomasa_PRAD),
                           FPAR_inv_t_3_var = extract(FPAR_inv_tex_3_var, biomasa_PRAD),
                           
                           FVC_inv_t_3_dis = extract(FVC_inv_tex_3_dis, biomasa_PRAD),
                           FVC_inv_t_3_mea = extract(FVC_inv_tex_3_mea, biomasa_PRAD),
                           FVC_inv_t_3_var = extract(FVC_inv_tex_3_var, biomasa_PRAD),
                           
                           # VIs
                           
                           GNDVI_ver_t_3_dis = extract(GNDVI_ver_tex_3_dis, biomasa_PRAD),
                           GNDVI_ver_t_3_mea = extract(GNDVI_ver_tex_3_mea, biomasa_PRAD),
                           GNDVI_ver_t_3_var= extract(GNDVI_ver_tex_3_var, biomasa_PRAD),
                           
                           IRECI_ver_t_3_dis = extract(IRECI_ver_tex_3_dis, biomasa_PRAD),
                           IRECI_ver_t_3_mea = extract(IRECI_ver_tex_3_mea, biomasa_PRAD),
                           IRECI_ver_t_3_var = extract(IRECI_ver_tex_3_var, biomasa_PRAD),
                           
                           NDI45_ver_t_3_dis = extract(NDI45_ver_tex_3_dis, biomasa_PRAD),
                           NDI45_ver_t_3_mea = extract(NDI45_ver_tex_3_mea, biomasa_PRAD),
                           NDI45_ver_t_3_var = extract(NDI45_ver_tex_3_var, biomasa_PRAD),
                           
                           NDVI_ver_t_3_dis = extract(NDVI_ver_tex_3_dis, biomasa_PRAD),
                           NDVI_ver_t_3_mea = extract(NDVI_ver_tex_3_mea, biomasa_PRAD),
                           NDVI_ver_t_3_var = extract(NDVI_ver_tex_3_var, biomasa_PRAD),
                           
                           SAVI_ver_t_3_dis = extract(SAVI_ver_tex_3_dis, biomasa_PRAD),
                           SAVI_ver_t_3_mea = extract(SAVI_ver_tex_3_mea, biomasa_PRAD),
                           SAVI_ver_t_3_var = extract(SAVI_ver_tex_3_var, biomasa_PRAD),
                           
                           TNDVI_ver_t_3_dis = extract(TNDVI_ver_tex_3_dis, biomasa_PRAD),
                           TNDVI_ver_t_3_mea = extract(TNDVI_ver_tex_3_mea, biomasa_PRAD),
                           TNDVI_ver_t_3_var = extract(TNDVI_ver_tex_3_var, biomasa_PRAD),
                           
                           GNDVI_inv_t_3_dis = extract(GNDVI_inv_tex_3_dis, biomasa_PRAD),
                           GNDVI_inv_t_3_mea = extract(GNDVI_inv_tex_3_mea, biomasa_PRAD),
                           GNDVI_inv_t_3_var= extract(GNDVI_inv_tex_3_var, biomasa_PRAD),
                           
                           IRECI_inv_t_3_dis = extract(IRECI_inv_tex_3_dis, biomasa_PRAD),
                           IRECI_inv_t_3_mea = extract(IRECI_inv_tex_3_mea, biomasa_PRAD),
                           IRECI_inv_t_3_var = extract(IRECI_inv_tex_3_var, biomasa_PRAD),
                           
                           NDI45_inv_t_3_dis = extract(NDI45_inv_tex_3_dis, biomasa_PRAD),
                           NDI45_inv_t_3_mea = extract(NDI45_inv_tex_3_mea, biomasa_PRAD),
                           NDI45_inv_t_3_var = extract(NDI45_inv_tex_3_var, biomasa_PRAD),
                           
                           NDVI_inv_t_3_dis = extract(NDVI_inv_tex_3_dis, biomasa_PRAD),
                           NDVI_inv_t_3_mea = extract(NDVI_inv_tex_3_mea, biomasa_PRAD),
                           NDVI_inv_t_3_var = extract(NDVI_inv_tex_3_var, biomasa_PRAD),
                           
                           SAVI_inv_t_3_dis = extract(SAVI_inv_tex_3_dis, biomasa_PRAD),
                           SAVI_inv_t_3_mea = extract(SAVI_inv_tex_3_mea, biomasa_PRAD),
                           SAVI_inv_t_3_var = extract(SAVI_inv_tex_3_var, biomasa_PRAD),
                           
                           TNDVI_inv_t_3_dis = extract(TNDVI_inv_tex_3_dis, biomasa_PRAD),
                           TNDVI_inv_t_3_mea = extract(TNDVI_inv_tex_3_mea, biomasa_PRAD),
                           TNDVI_inv_t_3_var = extract(TNDVI_inv_tex_3_var, biomasa_PRAD),
                           
                           # topographic variables
                           
                           slope_t_3_dis = extract(slope_tex_3_dis, biomasa_PRAD),
                           slope_t_3_mea = extract(slope_tex_3_dis, biomasa_PRAD),
                           slope_t_3_dis = extract(slope_tex_3_mea, biomasa_PRAD),
                           
                           aspect_t_3_dis = extract(aspect_tex_3_dis, biomasa_PRAD),
                           aspect_t_3_mea = extract(aspect_tex_3_mea, biomasa_PRAD),
                           aspect_t_3_var = extract(aspect_tex_3_var, biomasa_PRAD),
                           
                           cnbl_t_3_dis = extract(cnbl_tex_3_dis, biomasa_PRAD),
                           cnbl_t_3_mea = extract(cnbl_tex_3_mea, biomasa_PRAD),
                           cnbl_t_3_var = extract(cnbl_tex_3_var, biomasa_PRAD),
                           
                           cnd_t_3_dis =  extract(cnd_tex_3_dis, biomasa_PRAD),
                           cnd_t_3_mea=  extract(cnd_tex_3_mea, biomasa_PRAD),
                           cnd_t_3_var =  extract(cnd_tex_3_var, biomasa_PRAD),
                           
                           CI_t_3_dis = extract(CI_tex_3_dis, biomasa_PRAD),
                           CI_t_3_mea = extract(CI_tex_3_mea, biomasa_PRAD),
                           CI_t_3_var = extract(CI_tex_3_var, biomasa_PRAD),
                           
                           LS_factor_t_3_dis = extract(LS_factor_tex_3_dis, biomasa_PRAD),
                           LS_factor_t_3_mea = extract(LS_factor_tex_3_mea, biomasa_PRAD),
                           LS_factor_t_3_var = extract(LS_factor_tex_3_var, biomasa_PRAD),
                           
                           PlanC_t_3_dis = extract(PlanCurv_tex_3_dis, biomasa_PRAD),
                           PlanC_t_3_mea = extract(PlanCurv_tex_3_mea, biomasa_PRAD),
                           PlanC_t_3_var = extract(PlanCurv_tex_3_var, biomasa_PRAD),
                           
                           ProfC_t_3_dis = extract(ProfCurv_tex_3_dis, biomasa_PRAD),
                           ProfC_t_3_mea = extract(ProfCurv_tex_3_mea, biomasa_PRAD),
                           ProfC_t_3_var = extract(ProfCurv_tex_3_var, biomasa_PRAD),
                           
                           TWI_t_3_dis = extract(TWI_tex_3_dis, biomasa_PRAD),
                           TWI_t_3_mea = extract(TWI_tex_3_mea, biomasa_PRAD),
                           TWI_t_3_var = extract(TWI_tex_3_var, biomasa_PRAD)
                           
                           )

write.csv(biomasa_prad_df,'biomasa_PRAD_predictoras_f.csv')

# Native forests

structure(biomasa_BN@data)
biomasa_bn_df = data.frame(parcela = biomasa_BN$Parcela,
                           #GPS = biomasa_BN$GPS,
                           #x = biomasa_BN$X,
                           #y = biomasa_BN$Y,
                           #x_utm = biomasa_BN$X_UTM,
                           #y_utm = biomasa_BN$Y_UTM,
                           #AGB_kg = biomasa_BN$AGB..kg.,
                           #AGB_ton = biomasa_BN$AGB..ton.,
                           #sup_m2 = biomasa_BN$Sup__m2_,
                           AGB_ton_ha = biomasa_BN$AGB_ton_ha,
                           MDC_m = extract(MDC, biomasa_BN),
                           DEM_m = extract(DEM, biomasa_BN),
                           TX = extract(TX, biomasa_BN),
                           B2_ver = extract(B2_ver, biomasa_BN),
                           B3_ver = extract(B3_ver, biomasa_BN),
                           B4_ver = extract(B4_ver, biomasa_BN),
                           B5_ver = extract(B5_ver, biomasa_BN),
                           B6_ver = extract(B6_ver, biomasa_BN),
                           B7_ver = extract(B7_ver, biomasa_BN),
                           B8a_ver = extract(B8a_ver, biomasa_BN),
                           B11_ver = extract(B11_ver, biomasa_BN),
                           B12_ver = extract(B12_ver, biomasa_BN),
                           
                           LAI_ver = extract(LAI_ver, biomasa_BN),
                           Cab_ver = extract(Cab_ver, biomasa_BN),
                           Cwc_ver = extract(Cwc_ver, biomasa_BN),
                           FPAR_ver = extract(FPAR_ver, biomasa_BN),
                           FVC_ver = extract(FVC_ver, biomasa_BN),
                           GNDVI_ver = extract(GNDVI_ver, biomasa_BN),
                           IRECI_ver = extract(IRECI_ver, biomasa_BN),
                           NDI45_ver = extract(NDI45_ver, biomasa_BN),
                           NDVI_ver = extract(NDVI_ver, biomasa_BN),
                           SAVI_ver = extract(SAVI_ver, biomasa_BN),
                           TNDVI_ver = extract(TNDVI_ver, biomasa_BN),
                           B2_inv = extract(B2_inv, biomasa_BN),
                           B3_inv = extract(B3_inv, biomasa_BN),
                           B4_inv = extract(B4_inv, biomasa_BN),
                           B5_inv = extract(B5_inv, biomasa_BN),
                           B6_inv = extract(B6_inv, biomasa_BN),
                           B7_inv = extract(B7_inv, biomasa_BN),
                           B8a_inv = extract(B8a_inv, biomasa_BN),
                           B11_inv = extract(B11_inv, biomasa_BN),
                           B12_inv = extract(B12_inv, biomasa_BN),
                           LAI_inv = extract(LAI_inv, biomasa_BN),
                           Cab_inv = extract(Cab_inv, biomasa_BN),
                           Cwc_inv = extract(Cwc_inv, biomasa_BN),
                           FPAR_inv = extract(FPAR_inv, biomasa_BN),
                           FVC_inv = extract(FVC_inv, biomasa_BN),
                           GNDVI_inv = extract(GNDVI_inv, biomasa_BN),
                           IRECI_inv = extract(IRECI_inv, biomasa_BN),
                           NDI45_inv = extract(NDI45_inv, biomasa_BN),
                           NDVI_inv = extract(NDVI_inv, biomasa_BN),
                           SAVI_inv = extract(SAVI_inv, biomasa_BN),
                           TNDVI_inv = extract(TNDVI_inv, biomasa_BN),
                           slope = extract(slope, biomasa_BN),
                           aspect = extract(aspect, biomasa_BN),
                           cnbl = extract(cnbl, biomasa_BN),
                           cnd = extract(cnd, biomasa_BN),
                           CI = extract(CI, biomasa_BN),
                           LS_factor = extract(LS_factor, biomasa_BN),
                           PlanCurv = extract(PlanCurv, biomasa_BN),
                           ProfCurv = extract(ProfCurv, biomasa_BN),
                           TWI = extract(TWI, biomasa_BN),
                           
                           B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_BN),
                           B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_BN),
                           B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_BN),
                           B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_BN),
                           B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_BN),
                           B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_BN),
                           
                           B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_BN),
                           B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_BN),
                           B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_BN),
                           B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_BN),
                           B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_BN),
                           B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_BN),
                           
                           B03_i_t_3_dis = extract(B03_inv_tex_3_dis, biomasa_BN),
                           B03_i_t_3_mea = extract(B03_inv_tex_3_mea, biomasa_BN),
                           B03_i_t_3_var = extract(B03_inv_tex_3_var, biomasa_BN),
                           B03_v_t_3_dis = extract(B03_ver_tex_3_dis, biomasa_BN),
                           B03_v_t_3_mea = extract(B03_ver_tex_3_mea, biomasa_BN),
                           B03_v_t_3_var = extract(B03_ver_tex_3_var, biomasa_BN),
                           
                           B04_i_t_3_dis = extract(B04_inv_tex_3_dis, biomasa_BN),
                           B04_i_t_3_mea = extract(B04_inv_tex_3_mea, biomasa_BN),
                           B04_i_t_3_var = extract(B04_inv_tex_3_var, biomasa_BN),
                           B04_v_t_3_dis = extract(B04_ver_tex_3_dis, biomasa_BN),
                           B04_v_t_3_mea = extract(B04_ver_tex_3_mea, biomasa_BN),
                           B04_v_t_3_var = extract(B04_ver_tex_3_var, biomasa_BN),
                           
                           B05_i_t_3_dis = extract(B05_inv_tex_3_dis, biomasa_BN),
                           B05_i_t_3_mea = extract(B05_inv_tex_3_mea, biomasa_BN),
                           B05_i_t_3_var = extract(B05_inv_tex_3_var, biomasa_BN),
                           B05_v_t_3_dis = extract(B05_ver_tex_3_dis, biomasa_BN),
                           B05_v_t_3_mea = extract(B05_ver_tex_3_mea, biomasa_BN),
                           B05_v_t_3_var = extract(B05_ver_tex_3_var, biomasa_BN),
                           
                           B06_i_t_3_dis = extract(B06_inv_tex_3_dis, biomasa_BN),
                           B06_i_t_3_mea = extract(B06_inv_tex_3_mea, biomasa_BN),
                           B06_i_t_3_var = extract(B06_inv_tex_3_var, biomasa_BN),
                           B06_v_t_3_dis = extract(B06_ver_tex_3_dis, biomasa_BN),
                           B06_v_t_3_mea = extract(B06_ver_tex_3_mea, biomasa_BN),
                           B06_v_t_3_var = extract(B06_ver_tex_3_var, biomasa_BN),
                           
                           B07_i_t_3_dis = extract(B07_inv_tex_3_dis, biomasa_BN),
                           B07_i_t_3_mea = extract(B07_inv_tex_3_mea, biomasa_BN),
                           B07_i_t_3_var = extract(B07_inv_tex_3_var, biomasa_BN),
                           B07_v_t_3_dis = extract(B07_ver_tex_3_dis, biomasa_BN),
                           B07_v_t_3_mea = extract(B07_ver_tex_3_mea, biomasa_BN),
                           B07_v_t_3_var = extract(B07_ver_tex_3_var, biomasa_BN),
                           
                           B08a_i_t_3_dis = extract(B08a_inv_tex_3_dis, biomasa_BN),
                           B08a_i_t_3_mea = extract(B08a_inv_tex_3_mea, biomasa_BN),
                           B08a_i_t_3_var = extract(B08a_inv_tex_3_var, biomasa_BN),
                           B08a_v_t_3_dis = extract(B08a_ver_tex_3_dis, biomasa_BN),
                           B08a_v_t_3_mea = extract(B08a_ver_tex_3_mea, biomasa_BN),
                           B08a_v_t_3_var = extract(B08a_ver_tex_3_var, biomasa_BN),
                           
                           B11_i_t_3_dis = extract(B11_inv_tex_3_dis, biomasa_BN),
                           B11_i_t_3_mea = extract(B11_inv_tex_3_mea, biomasa_BN),
                           B11_i_t_3_var = extract(B11_inv_tex_3_var, biomasa_BN),
                           B11_v_t_3_dis = extract(B11_ver_tex_3_dis, biomasa_BN),
                           B11_v_t_3_mea = extract(B11_ver_tex_3_mea, biomasa_BN),
                           B11_v_t_3_var = extract(B11_ver_tex_3_var, biomasa_BN),
                           
                           B12_i_t_3_dis = extract(B12_inv_tex_3_dis, biomasa_BN),
                           B12_i_t_3_mea = extract(B12_inv_tex_3_mea, biomasa_BN),
                           B12_i_t_3_var = extract(B12_inv_tex_3_var, biomasa_BN),
                           B12_v_t_3_dis = extract(B12_ver_tex_3_dis, biomasa_BN),
                           B12_v_t_3_mea = extract(B12_ver_tex_3_mea, biomasa_BN),
                           B12_v_t_3_var = extract(B12_ver_tex_3_var, biomasa_BN),
                           
                           MDC_t_3_dis = extract(MDC_tex_3_dis, biomasa_BN),
                           MDC_t_3_mea = extract(MDC_tex_3_mea, biomasa_BN),
                           MDC_t_3_var = extract(MDC_tex_3_var, biomasa_BN),
                           
                           DEM_t_3_dis = extract(DEM_tex_3_dis, biomasa_BN),
                           DEM_t_3_mea = extract(DEM_tex_3_mea, biomasa_BN),
                           DEM_t_3_var = extract(DEM_tex_3_var, biomasa_BN),
                           
                           TX_t_3_dis = extract(TX_tex_3_dis, biomasa_BN),
                           TX_t_3_mea = extract(TX_tex_3_mea, biomasa_BN),
                           TX_t_3_var = extract(TX_tex_3_var, biomasa_BN),
                           
                           # biopyhsical
                           
                           LAI_ver_t_3_dis = extract(LAI_ver_tex_3_dis, biomasa_BN),
                           LAI_ver_t_3_mea = extract(LAI_ver_tex_3_mea, biomasa_BN),
                           LAI_ver_t_3_var = extract(LAI_ver_tex_3_var, biomasa_BN),
                           
                           Cab_ver_t_3_dis = extract(Cab_ver_tex_3_dis, biomasa_BN),
                           Cab_ver_t_3_mea = extract(Cab_ver_tex_3_mea, biomasa_BN),
                           Cab_ver_t_3_var = extract(Cab_ver_tex_3_var, biomasa_BN),
                           
                           Cwc_ver_t_3_dis = extract(Cwc_ver_tex_3_dis, biomasa_BN),
                           Cwc_ver_t_3_mea = extract(Cwc_ver_tex_3_mea, biomasa_BN),
                           Cwc_ver_t_3_var = extract(Cwc_ver_tex_3_var, biomasa_BN),
                           
                           FPAR_ver_t_3_dis = extract(FPAR_ver_tex_3_dis, biomasa_BN),
                           FPAR_ver_t_3_mea = extract(FPAR_ver_tex_3_mea, biomasa_BN),
                           FPAR_ver_t_3_var = extract(FPAR_ver_tex_3_var, biomasa_BN),
                           
                           FVC_ver_t_3_dis = extract(FVC_ver_tex_3_dis, biomasa_BN),
                           FVC_ver_t_3_mea = extract(FVC_ver_tex_3_mea, biomasa_BN),
                           FVC_ver_t_3_var = extract(FVC_ver_tex_3_var, biomasa_BN),
                           
                           
                           LAI_inv_t_3_dis = extract(LAI_inv_tex_3_dis, biomasa_BN),
                           LAI_inv_t_3_mea = extract(LAI_inv_tex_3_mea, biomasa_BN),
                           LAI_inv_t_3_var = extract(LAI_inv_tex_3_var, biomasa_BN),
                           
                           Cab_inv_t_3_dis = extract(Cab_inv_tex_3_dis, biomasa_BN),
                           Cab_inv_t_3_mea = extract(Cab_inv_tex_3_mea, biomasa_BN),
                           Cab_inv_t_3_var = extract(Cab_inv_tex_3_var, biomasa_BN),
                           
                           Cwc_inv_t_3_dis = extract(Cwc_inv_tex_3_dis, biomasa_BN),
                           Cwc_inv_t_3_mea = extract(Cwc_inv_tex_3_mea, biomasa_BN),
                           Cwc_inv_t_3_var = extract(Cwc_inv_tex_3_var, biomasa_BN),
                           
                           FPAR_inv_t_3_dis = extract(FPAR_inv_tex_3_dis, biomasa_BN),
                           FPAR_inv_t_3_mea = extract(FPAR_inv_tex_3_mea, biomasa_BN),
                           FPAR_inv_t_3_var = extract(FPAR_inv_tex_3_var, biomasa_BN),
                           
                           FVC_inv_t_3_dis = extract(FVC_inv_tex_3_dis, biomasa_BN),
                           FVC_inv_t_3_mea = extract(FVC_inv_tex_3_mea, biomasa_BN),
                           FVC_inv_t_3_var = extract(FVC_inv_tex_3_var, biomasa_BN),
                           
                           # VIs
                           
                           GNDVI_ver_t_3_dis = extract(GNDVI_ver_tex_3_dis, biomasa_BN),
                           GNDVI_ver_t_3_mea = extract(GNDVI_ver_tex_3_mea, biomasa_BN),
                           GNDVI_ver_t_3_var= extract(GNDVI_ver_tex_3_var, biomasa_BN),
                           
                           IRECI_ver_t_3_dis = extract(IRECI_ver_tex_3_dis, biomasa_BN),
                           IRECI_ver_t_3_mea = extract(IRECI_ver_tex_3_mea, biomasa_BN),
                           IRECI_ver_t_3_var = extract(IRECI_ver_tex_3_var, biomasa_BN),
                           
                           NDI45_ver_t_3_dis = extract(NDI45_ver_tex_3_dis, biomasa_BN),
                           NDI45_ver_t_3_mea = extract(NDI45_ver_tex_3_mea, biomasa_BN),
                           NDI45_ver_t_3_var = extract(NDI45_ver_tex_3_var, biomasa_BN),
                           
                           NDVI_ver_t_3_dis = extract(NDVI_ver_tex_3_dis, biomasa_BN),
                           NDVI_ver_t_3_mea = extract(NDVI_ver_tex_3_mea, biomasa_BN),
                           NDVI_ver_t_3_var = extract(NDVI_ver_tex_3_var, biomasa_BN),
                           
                           SAVI_ver_t_3_dis = extract(SAVI_ver_tex_3_dis, biomasa_BN),
                           SAVI_ver_t_3_mea = extract(SAVI_ver_tex_3_mea, biomasa_BN),
                           SAVI_ver_t_3_var = extract(SAVI_ver_tex_3_var, biomasa_BN),
                           
                           TNDVI_ver_t_3_dis = extract(TNDVI_ver_tex_3_dis, biomasa_BN),
                           TNDVI_ver_t_3_mea = extract(TNDVI_ver_tex_3_mea, biomasa_BN),
                           TNDVI_ver_t_3_var = extract(TNDVI_ver_tex_3_var, biomasa_BN),
                           
                           GNDVI_inv_t_3_dis = extract(GNDVI_inv_tex_3_dis, biomasa_BN),
                           GNDVI_inv_t_3_mea = extract(GNDVI_inv_tex_3_mea, biomasa_BN),
                           GNDVI_inv_t_3_var= extract(GNDVI_inv_tex_3_var, biomasa_BN),
                           
                           IRECI_inv_t_3_dis = extract(IRECI_inv_tex_3_dis, biomasa_BN),
                           IRECI_inv_t_3_mea = extract(IRECI_inv_tex_3_mea, biomasa_BN),
                           IRECI_inv_t_3_var = extract(IRECI_inv_tex_3_var, biomasa_BN),
                           
                           NDI45_inv_t_3_dis = extract(NDI45_inv_tex_3_dis, biomasa_BN),
                           NDI45_inv_t_3_mea = extract(NDI45_inv_tex_3_mea, biomasa_BN),
                           NDI45_inv_t_3_var = extract(NDI45_inv_tex_3_var, biomasa_BN),
                           
                           NDVI_inv_t_3_dis = extract(NDVI_inv_tex_3_dis, biomasa_BN),
                           NDVI_inv_t_3_mea = extract(NDVI_inv_tex_3_mea, biomasa_BN),
                           NDVI_inv_t_3_var = extract(NDVI_inv_tex_3_var, biomasa_BN),
                           
                           SAVI_inv_t_3_dis = extract(SAVI_inv_tex_3_dis, biomasa_BN),
                           SAVI_inv_t_3_mea = extract(SAVI_inv_tex_3_mea, biomasa_BN),
                           SAVI_inv_t_3_var = extract(SAVI_inv_tex_3_var, biomasa_BN),
                           
                           TNDVI_inv_t_3_dis = extract(TNDVI_inv_tex_3_dis, biomasa_BN),
                           TNDVI_inv_t_3_mea = extract(TNDVI_inv_tex_3_mea, biomasa_BN),
                           TNDVI_inv_t_3_var = extract(TNDVI_inv_tex_3_var, biomasa_BN),
                           
                           # topographic variables
                           
                           slope_t_3_dis = extract(slope_tex_3_dis, biomasa_BN),
                           slope_t_3_mea = extract(slope_tex_3_dis, biomasa_BN),
                           slope_t_3_dis = extract(slope_tex_3_mea, biomasa_BN),
                           
                           aspect_t_3_dis = extract(aspect_tex_3_dis, biomasa_BN),
                           aspect_t_3_mea = extract(aspect_tex_3_mea, biomasa_BN),
                           aspect_t_3_var = extract(aspect_tex_3_var, biomasa_BN),
                           
                           cnbl_t_3_dis = extract(cnbl_tex_3_dis, biomasa_BN),
                           cnbl_t_3_mea = extract(cnbl_tex_3_mea, biomasa_BN),
                           cnbl_t_3_var = extract(cnbl_tex_3_var, biomasa_BN),
                           
                           cnd_t_3_dis =  extract(cnd_tex_3_dis, biomasa_BN),
                           cnd_t_3_mea=  extract(cnd_tex_3_mea, biomasa_BN),
                           cnd_t_3_var =  extract(cnd_tex_3_var, biomasa_BN),
                           
                           CI_t_3_dis = extract(CI_tex_3_dis, biomasa_BN),
                           CI_t_3_mea = extract(CI_tex_3_mea, biomasa_BN),
                           CI_t_3_var = extract(CI_tex_3_var, biomasa_BN),
                           
                           LS_factor_t_3_dis = extract(LS_factor_tex_3_dis, biomasa_BN),
                           LS_factor_t_3_mea = extract(LS_factor_tex_3_mea, biomasa_BN),
                           LS_factor_t_3_var = extract(LS_factor_tex_3_var, biomasa_BN),
                           
                           PlanC_t_3_dis = extract(PlanCurv_tex_3_dis, biomasa_BN),
                           PlanC_t_3_mea = extract(PlanCurv_tex_3_mea, biomasa_BN),
                           PlanC_t_3_var = extract(PlanCurv_tex_3_var, biomasa_BN),
                           
                           ProfC_t_3_dis = extract(ProfCurv_tex_3_dis, biomasa_BN),
                           ProfC_t_3_mea = extract(ProfCurv_tex_3_mea, biomasa_BN),
                           ProfC_t_3_var = extract(ProfCurv_tex_3_var, biomasa_BN),
                           
                           TWI_t_3_dis = extract(TWI_tex_3_dis, biomasa_BN),
                           TWI_t_3_mea = extract(TWI_tex_3_mea, biomasa_BN),
                           TWI_t_3_var = extract(TWI_tex_3_var, biomasa_BN))


write.csv(biomasa_bn_df,'biomasa_BN_predictoras_f.csv')

# Pine plantations

biomasa_PINO_df = data.frame(parcela = biomasa_PINO$Parcela,
                             #GPS = biomasa_PINO$GPS,
                             #x = biomasa_PINO$X,
                             #y = biomasa_PINO$Y,
                             #x_utm = biomasa_PINO$X_UTM,
                             #y_utm = biomasa_PINO$Y_UTM,
                             #AGB_kg = biomasa_PINO$AGB__kg_,
                             #AGB_ton = biomasa_PINO$AGB__ton_,
                             #sup_m2 = biomasa_PINO$Sup__m2_,
                             AGB_ton_ha = biomasa_PINO$AGB__ton_h,
                             MDC_m = extract(MDC, biomasa_PINO),
                             DEM_m = extract(DEM, biomasa_PINO),
                             TX = extract(TX, biomasa_PINO),
                             B2_ver = extract(B2_ver, biomasa_PINO),
                             B3_ver = extract(B3_ver, biomasa_PINO),
                             B4_ver = extract(B4_ver, biomasa_PINO),
                             B5_ver = extract(B5_ver, biomasa_PINO),
                             B6_ver = extract(B6_ver, biomasa_PINO),
                             B7_ver = extract(B7_ver, biomasa_PINO),
                             B8a_ver = extract(B8a_ver, biomasa_PINO),
                             B11_ver = extract(B11_ver, biomasa_PINO),
                             B12_ver = extract(B12_ver, biomasa_PINO),
                             
                             LAI_ver = extract(LAI_ver, biomasa_PINO),
                             Cab_ver = extract(Cab_ver, biomasa_PINO),
                             Cwc_ver = extract(Cwc_ver, biomasa_PINO),
                             FPAR_ver = extract(FPAR_ver, biomasa_PINO),
                             FVC_ver = extract(FVC_ver, biomasa_PINO),
                             GNDVI_ver = extract(GNDVI_ver, biomasa_PINO),
                             IRECI_ver = extract(IRECI_ver, biomasa_PINO),
                             NDI45_ver = extract(NDI45_ver, biomasa_PINO),
                             NDVI_ver = extract(NDVI_ver, biomasa_PINO),
                             SAVI_ver = extract(SAVI_ver, biomasa_PINO),
                             TNDVI_ver = extract(TNDVI_ver, biomasa_PINO),
                             B2_inv = extract(B2_inv, biomasa_PINO),
                             B3_inv = extract(B3_inv, biomasa_PINO),
                             B4_inv = extract(B4_inv, biomasa_PINO),
                             B5_inv = extract(B5_inv, biomasa_PINO),
                             B6_inv = extract(B6_inv, biomasa_PINO),
                             B7_inv = extract(B7_inv, biomasa_PINO),
                             B8a_inv = extract(B8a_inv, biomasa_PINO),
                             B11_inv = extract(B11_inv, biomasa_PINO),
                             B12_inv = extract(B12_inv, biomasa_PINO),
                             LAI_inv = extract(LAI_inv, biomasa_PINO),
                             Cab_inv = extract(Cab_inv, biomasa_PINO),
                             Cwc_inv = extract(Cwc_inv, biomasa_PINO),
                             FPAR_inv = extract(FPAR_inv, biomasa_PINO),
                             FVC_inv = extract(FVC_inv, biomasa_PINO),
                             GNDVI_inv = extract(GNDVI_inv, biomasa_PINO),
                             IRECI_inv = extract(IRECI_inv, biomasa_PINO),
                             NDI45_inv = extract(NDI45_inv, biomasa_PINO),
                             NDVI_inv = extract(NDVI_inv, biomasa_PINO),
                             SAVI_inv = extract(SAVI_inv, biomasa_PINO),
                             TNDVI_inv = extract(TNDVI_inv, biomasa_PINO),
                             slope = extract(slope, biomasa_PINO),
                             aspect = extract(aspect, biomasa_PINO),
                             cnbl = extract(cnbl, biomasa_PINO),
                             cnd = extract(cnd, biomasa_PINO),
                             CI = extract(CI, biomasa_PINO),
                             LS_factor = extract(LS_factor, biomasa_PINO),
                             PlanCurv = extract(PlanCurv, biomasa_PINO),
                             ProfCurv = extract(ProfCurv, biomasa_PINO),
                             TWI = extract(TWI, biomasa_PINO),
                             
                             B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_PINO),
                             B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_PINO),
                             B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_PINO),
                             B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_PINO),
                             B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_PINO),
                             B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_PINO),
                             
                             B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_PINO),
                             B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_PINO),
                             B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_PINO),
                             B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_PINO),
                             B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_PINO),
                             B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_PINO),
                             
                             B03_i_t_3_dis = extract(B03_inv_tex_3_dis, biomasa_PINO),
                             B03_i_t_3_mea = extract(B03_inv_tex_3_mea, biomasa_PINO),
                             B03_i_t_3_var = extract(B03_inv_tex_3_var, biomasa_PINO),
                             B03_v_t_3_dis = extract(B03_ver_tex_3_dis, biomasa_PINO),
                             B03_v_t_3_mea = extract(B03_ver_tex_3_mea, biomasa_PINO),
                             B03_v_t_3_var = extract(B03_ver_tex_3_var, biomasa_PINO),
                             
                             B04_i_t_3_dis = extract(B04_inv_tex_3_dis, biomasa_PINO),
                             B04_i_t_3_mea = extract(B04_inv_tex_3_mea, biomasa_PINO),
                             B04_i_t_3_var = extract(B04_inv_tex_3_var, biomasa_PINO),
                             B04_v_t_3_dis = extract(B04_ver_tex_3_dis, biomasa_PINO),
                             B04_v_t_3_mea = extract(B04_ver_tex_3_mea, biomasa_PINO),
                             B04_v_t_3_var = extract(B04_ver_tex_3_var, biomasa_PINO),
                             
                             B05_i_t_3_dis = extract(B05_inv_tex_3_dis, biomasa_PINO),
                             B05_i_t_3_mea = extract(B05_inv_tex_3_mea, biomasa_PINO),
                             B05_i_t_3_var = extract(B05_inv_tex_3_var, biomasa_PINO),
                             B05_v_t_3_dis = extract(B05_ver_tex_3_dis, biomasa_PINO),
                             B05_v_t_3_mea = extract(B05_ver_tex_3_mea, biomasa_PINO),
                             B05_v_t_3_var = extract(B05_ver_tex_3_var, biomasa_PINO),
                             
                             B06_i_t_3_dis = extract(B06_inv_tex_3_dis, biomasa_PINO),
                             B06_i_t_3_mea = extract(B06_inv_tex_3_mea, biomasa_PINO),
                             B06_i_t_3_var = extract(B06_inv_tex_3_var, biomasa_PINO),
                             B06_v_t_3_dis = extract(B06_ver_tex_3_dis, biomasa_PINO),
                             B06_v_t_3_mea = extract(B06_ver_tex_3_mea, biomasa_PINO),
                             B06_v_t_3_var = extract(B06_ver_tex_3_var, biomasa_PINO),
                             
                             B07_i_t_3_dis = extract(B07_inv_tex_3_dis, biomasa_PINO),
                             B07_i_t_3_mea = extract(B07_inv_tex_3_mea, biomasa_PINO),
                             B07_i_t_3_var = extract(B07_inv_tex_3_var, biomasa_PINO),
                             B07_v_t_3_dis = extract(B07_ver_tex_3_dis, biomasa_PINO),
                             B07_v_t_3_mea = extract(B07_ver_tex_3_mea, biomasa_PINO),
                             B07_v_t_3_var = extract(B07_ver_tex_3_var, biomasa_PINO),
                             
                             B08a_i_t_3_dis = extract(B08a_inv_tex_3_dis, biomasa_PINO),
                             B08a_i_t_3_mea = extract(B08a_inv_tex_3_mea, biomasa_PINO),
                             B08a_i_t_3_var = extract(B08a_inv_tex_3_var, biomasa_PINO),
                             B08a_v_t_3_dis = extract(B08a_ver_tex_3_dis, biomasa_PINO),
                             B08a_v_t_3_mea = extract(B08a_ver_tex_3_mea, biomasa_PINO),
                             B08a_v_t_3_var = extract(B08a_ver_tex_3_var, biomasa_PINO),
                             
                             B11_i_t_3_dis = extract(B11_inv_tex_3_dis, biomasa_PINO),
                             B11_i_t_3_mea = extract(B11_inv_tex_3_mea, biomasa_PINO),
                             B11_i_t_3_var = extract(B11_inv_tex_3_var, biomasa_PINO),
                             B11_v_t_3_dis = extract(B11_ver_tex_3_dis, biomasa_PINO),
                             B11_v_t_3_mea = extract(B11_ver_tex_3_mea, biomasa_PINO),
                             B11_v_t_3_var = extract(B11_ver_tex_3_var, biomasa_PINO),
                             
                             B12_i_t_3_dis = extract(B12_inv_tex_3_dis, biomasa_PINO),
                             B12_i_t_3_mea = extract(B12_inv_tex_3_mea, biomasa_PINO),
                             B12_i_t_3_var = extract(B12_inv_tex_3_var, biomasa_PINO),
                             B12_v_t_3_dis = extract(B12_ver_tex_3_dis, biomasa_PINO),
                             B12_v_t_3_mea = extract(B12_ver_tex_3_mea, biomasa_PINO),
                             B12_v_t_3_var = extract(B12_ver_tex_3_var, biomasa_PINO),
                             
                             MDC_t_3_dis = extract(MDC_tex_3_dis, biomasa_PINO),
                             MDC_t_3_mea = extract(MDC_tex_3_mea, biomasa_PINO),
                             MDC_t_3_var = extract(MDC_tex_3_var, biomasa_PINO),
                             
                             DEM_t_3_dis = extract(DEM_tex_3_dis, biomasa_PINO),
                             DEM_t_3_mea = extract(DEM_tex_3_mea, biomasa_PINO),
                             DEM_t_3_var = extract(DEM_tex_3_var, biomasa_PINO),
                             
                             TX_t_3_dis = extract(TX_tex_3_dis, biomasa_PINO),
                             TX_t_3_mea = extract(TX_tex_3_mea, biomasa_PINO),
                             TX_t_3_var = extract(TX_tex_3_var, biomasa_PINO),
                             
                             # biopyhsical
                             
                             LAI_ver_t_3_dis = extract(LAI_ver_tex_3_dis, biomasa_PINO),
                             LAI_ver_t_3_mea = extract(LAI_ver_tex_3_mea, biomasa_PINO),
                             LAI_ver_t_3_var = extract(LAI_ver_tex_3_var, biomasa_PINO),
                             
                             Cab_ver_t_3_dis = extract(Cab_ver_tex_3_dis, biomasa_PINO),
                             Cab_ver_t_3_mea = extract(Cab_ver_tex_3_mea, biomasa_PINO),
                             Cab_ver_t_3_var = extract(Cab_ver_tex_3_var, biomasa_PINO),
                             
                             Cwc_ver_t_3_dis = extract(Cwc_ver_tex_3_dis, biomasa_PINO),
                             Cwc_ver_t_3_mea = extract(Cwc_ver_tex_3_mea, biomasa_PINO),
                             Cwc_ver_t_3_var = extract(Cwc_ver_tex_3_var, biomasa_PINO),
                             
                             FPAR_ver_t_3_dis = extract(FPAR_ver_tex_3_dis, biomasa_PINO),
                             FPAR_ver_t_3_mea = extract(FPAR_ver_tex_3_mea, biomasa_PINO),
                             FPAR_ver_t_3_var = extract(FPAR_ver_tex_3_var, biomasa_PINO),
                             
                             FVC_ver_t_3_dis = extract(FVC_ver_tex_3_dis, biomasa_PINO),
                             FVC_ver_t_3_mea = extract(FVC_ver_tex_3_mea, biomasa_PINO),
                             FVC_ver_t_3_var = extract(FVC_ver_tex_3_var, biomasa_PINO),
                             
                             
                             LAI_inv_t_3_dis = extract(LAI_inv_tex_3_dis, biomasa_PINO),
                             LAI_inv_t_3_mea = extract(LAI_inv_tex_3_mea, biomasa_PINO),
                             LAI_inv_t_3_var = extract(LAI_inv_tex_3_var, biomasa_PINO),
                             
                             Cab_inv_t_3_dis = extract(Cab_inv_tex_3_dis, biomasa_PINO),
                             Cab_inv_t_3_mea = extract(Cab_inv_tex_3_mea, biomasa_PINO),
                             Cab_inv_t_3_var = extract(Cab_inv_tex_3_var, biomasa_PINO),
                             
                             Cwc_inv_t_3_dis = extract(Cwc_inv_tex_3_dis, biomasa_PINO),
                             Cwc_inv_t_3_mea = extract(Cwc_inv_tex_3_mea, biomasa_PINO),
                             Cwc_inv_t_3_var = extract(Cwc_inv_tex_3_var, biomasa_PINO),
                             
                             FPAR_inv_t_3_dis = extract(FPAR_inv_tex_3_dis, biomasa_PINO),
                             FPAR_inv_t_3_mea = extract(FPAR_inv_tex_3_mea, biomasa_PINO),
                             FPAR_inv_t_3_var = extract(FPAR_inv_tex_3_var, biomasa_PINO),
                             
                             FVC_inv_t_3_dis = extract(FVC_inv_tex_3_dis, biomasa_PINO),
                             FVC_inv_t_3_mea = extract(FVC_inv_tex_3_mea, biomasa_PINO),
                             FVC_inv_t_3_var = extract(FVC_inv_tex_3_var, biomasa_PINO),
                             
                             # VIs
                             
                             GNDVI_ver_t_3_dis = extract(GNDVI_ver_tex_3_dis, biomasa_PINO),
                             GNDVI_ver_t_3_mea = extract(GNDVI_ver_tex_3_mea, biomasa_PINO),
                             GNDVI_ver_t_3_var= extract(GNDVI_ver_tex_3_var, biomasa_PINO),
                             
                             IRECI_ver_t_3_dis = extract(IRECI_ver_tex_3_dis, biomasa_PINO),
                             IRECI_ver_t_3_mea = extract(IRECI_ver_tex_3_mea, biomasa_PINO),
                             IRECI_ver_t_3_var = extract(IRECI_ver_tex_3_var, biomasa_PINO),
                             
                             NDI45_ver_t_3_dis = extract(NDI45_ver_tex_3_dis, biomasa_PINO),
                             NDI45_ver_t_3_mea = extract(NDI45_ver_tex_3_mea, biomasa_PINO),
                             NDI45_ver_t_3_var = extract(NDI45_ver_tex_3_var, biomasa_PINO),
                             
                             NDVI_ver_t_3_dis = extract(NDVI_ver_tex_3_dis, biomasa_PINO),
                             NDVI_ver_t_3_mea = extract(NDVI_ver_tex_3_mea, biomasa_PINO),
                             NDVI_ver_t_3_var = extract(NDVI_ver_tex_3_var, biomasa_PINO),
                             
                             SAVI_ver_t_3_dis = extract(SAVI_ver_tex_3_dis, biomasa_PINO),
                             SAVI_ver_t_3_mea = extract(SAVI_ver_tex_3_mea, biomasa_PINO),
                             SAVI_ver_t_3_var = extract(SAVI_ver_tex_3_var, biomasa_PINO),
                             
                             TNDVI_ver_t_3_dis = extract(TNDVI_ver_tex_3_dis, biomasa_PINO),
                             TNDVI_ver_t_3_mea = extract(TNDVI_ver_tex_3_mea, biomasa_PINO),
                             TNDVI_ver_t_3_var = extract(TNDVI_ver_tex_3_var, biomasa_PINO),
                             
                             GNDVI_inv_t_3_dis = extract(GNDVI_inv_tex_3_dis, biomasa_PINO),
                             GNDVI_inv_t_3_mea = extract(GNDVI_inv_tex_3_mea, biomasa_PINO),
                             GNDVI_inv_t_3_var= extract(GNDVI_inv_tex_3_var, biomasa_PINO),
                             
                             IRECI_inv_t_3_dis = extract(IRECI_inv_tex_3_dis, biomasa_PINO),
                             IRECI_inv_t_3_mea = extract(IRECI_inv_tex_3_mea, biomasa_PINO),
                             IRECI_inv_t_3_var = extract(IRECI_inv_tex_3_var, biomasa_PINO),
                             
                             NDI45_inv_t_3_dis = extract(NDI45_inv_tex_3_dis, biomasa_PINO),
                             NDI45_inv_t_3_mea = extract(NDI45_inv_tex_3_mea, biomasa_PINO),
                             NDI45_inv_t_3_var = extract(NDI45_inv_tex_3_var, biomasa_PINO),
                             
                             NDVI_inv_t_3_dis = extract(NDVI_inv_tex_3_dis, biomasa_PINO),
                             NDVI_inv_t_3_mea = extract(NDVI_inv_tex_3_mea, biomasa_PINO),
                             NDVI_inv_t_3_var = extract(NDVI_inv_tex_3_var, biomasa_PINO),
                             
                             SAVI_inv_t_3_dis = extract(SAVI_inv_tex_3_dis, biomasa_PINO),
                             SAVI_inv_t_3_mea = extract(SAVI_inv_tex_3_mea, biomasa_PINO),
                             SAVI_inv_t_3_var = extract(SAVI_inv_tex_3_var, biomasa_PINO),
                             
                             TNDVI_inv_t_3_dis = extract(TNDVI_inv_tex_3_dis, biomasa_PINO),
                             TNDVI_inv_t_3_mea = extract(TNDVI_inv_tex_3_mea, biomasa_PINO),
                             TNDVI_inv_t_3_var = extract(TNDVI_inv_tex_3_var, biomasa_PINO),
                             
                             # topographic variables
                             
                             slope_t_3_dis = extract(slope_tex_3_dis, biomasa_PINO),
                             slope_t_3_mea = extract(slope_tex_3_dis, biomasa_PINO),
                             slope_t_3_dis = extract(slope_tex_3_mea, biomasa_PINO),
                             
                             aspect_t_3_dis = extract(aspect_tex_3_dis, biomasa_PINO),
                             aspect_t_3_mea = extract(aspect_tex_3_mea, biomasa_PINO),
                             aspect_t_3_var = extract(aspect_tex_3_var, biomasa_PINO),
                             
                             cnbl_t_3_dis = extract(cnbl_tex_3_dis, biomasa_PINO),
                             cnbl_t_3_mea = extract(cnbl_tex_3_mea, biomasa_PINO),
                             cnbl_t_3_var = extract(cnbl_tex_3_var, biomasa_PINO),
                             
                             cnd_t_3_dis =  extract(cnd_tex_3_dis, biomasa_PINO),
                             cnd_t_3_mea=  extract(cnd_tex_3_mea, biomasa_PINO),
                             cnd_t_3_var =  extract(cnd_tex_3_var, biomasa_PINO),
                             
                             CI_t_3_dis = extract(CI_tex_3_dis, biomasa_PINO),
                             CI_t_3_mea = extract(CI_tex_3_mea, biomasa_PINO),
                             CI_t_3_var = extract(CI_tex_3_var, biomasa_PINO),
                             
                             LS_factor_t_3_dis = extract(LS_factor_tex_3_dis, biomasa_PINO),
                             LS_factor_t_3_mea = extract(LS_factor_tex_3_mea, biomasa_PINO),
                             LS_factor_t_3_var = extract(LS_factor_tex_3_var, biomasa_PINO),
                             
                             PlanC_t_3_dis = extract(PlanCurv_tex_3_dis, biomasa_PINO),
                             PlanC_t_3_mea = extract(PlanCurv_tex_3_mea, biomasa_PINO),
                             PlanC_t_3_var = extract(PlanCurv_tex_3_var, biomasa_PINO),
                             
                             ProfC_t_3_dis = extract(ProfCurv_tex_3_dis, biomasa_PINO),
                             ProfC_t_3_mea = extract(ProfCurv_tex_3_mea, biomasa_PINO),
                             ProfC_t_3_var = extract(ProfCurv_tex_3_var, biomasa_PINO),
                             
                             TWI_t_3_dis = extract(TWI_tex_3_dis, biomasa_PINO),
                             TWI_t_3_mea = extract(TWI_tex_3_mea, biomasa_PINO),
                             TWI_t_3_var = extract(TWI_tex_3_var, biomasa_PINO))

write.csv(biomasa_PINO_df,'biomasa_PINO_predictoras_f.csv')



# Shrublands

colnames(biomasa_MAT@data)

biomasa_mat_df = data.frame(parcela = biomasa_MAT$Parcela,
                             #GPS = biomasa_MAT$GPS,
                             #x = biomasa_MAT$X,
                             #y = biomasa_MAT$Y,
                             #x_utm = biomasa_MAT$X_UTM,
                             #y_utm = biomasa_MAT$Y_UTM,
                             #AGB_kg = biomasa_MAT$AGB__kg_,
                             #AGB_ton = biomasa_MAT$AGB__ton_,
                             #sup_m2 = biomasa_MAT$Sup__m2_,
                             AGB_ton_ha = biomasa_MAT$AGB..ton.h,
                             MDC_m = extract(MDC, biomasa_MAT),
                             DEM_m = extract(DEM, biomasa_MAT),
                             TX = extract(TX, biomasa_MAT),
                             B2_ver = extract(B2_ver, biomasa_MAT),
                             B3_ver = extract(B3_ver, biomasa_MAT),
                             B4_ver = extract(B4_ver, biomasa_MAT),
                             B5_ver = extract(B5_ver, biomasa_MAT),
                             B6_ver = extract(B6_ver, biomasa_MAT),
                             B7_ver = extract(B7_ver, biomasa_MAT),
                             B8a_ver = extract(B8a_ver, biomasa_MAT),
                             B11_ver = extract(B11_ver, biomasa_MAT),
                             B12_ver = extract(B12_ver, biomasa_MAT),
                             
                             LAI_ver = extract(LAI_ver, biomasa_MAT),
                             Cab_ver = extract(Cab_ver, biomasa_MAT),
                             Cwc_ver = extract(Cwc_ver, biomasa_MAT),
                             FPAR_ver = extract(FPAR_ver, biomasa_MAT),
                             FVC_ver = extract(FVC_ver, biomasa_MAT),
                             GNDVI_ver = extract(GNDVI_ver, biomasa_MAT),
                             IRECI_ver = extract(IRECI_ver, biomasa_MAT),
                             NDI45_ver = extract(NDI45_ver, biomasa_MAT),
                             NDVI_ver = extract(NDVI_ver, biomasa_MAT),
                             SAVI_ver = extract(SAVI_ver, biomasa_MAT),
                             TNDVI_ver = extract(TNDVI_ver, biomasa_MAT),
                             B2_inv = extract(B2_inv, biomasa_MAT),
                             B3_inv = extract(B3_inv, biomasa_MAT),
                             B4_inv = extract(B4_inv, biomasa_MAT),
                             B5_inv = extract(B5_inv, biomasa_MAT),
                             B6_inv = extract(B6_inv, biomasa_MAT),
                             B7_inv = extract(B7_inv, biomasa_MAT),
                             B8a_inv = extract(B8a_inv, biomasa_MAT),
                             B11_inv = extract(B11_inv, biomasa_MAT),
                             B12_inv = extract(B12_inv, biomasa_MAT),
                             LAI_inv = extract(LAI_inv, biomasa_MAT),
                             Cab_inv = extract(Cab_inv, biomasa_MAT),
                             Cwc_inv = extract(Cwc_inv, biomasa_MAT),
                             FPAR_inv = extract(FPAR_inv, biomasa_MAT),
                             FVC_inv = extract(FVC_inv, biomasa_MAT),
                             GNDVI_inv = extract(GNDVI_inv, biomasa_MAT),
                             IRECI_inv = extract(IRECI_inv, biomasa_MAT),
                             NDI45_inv = extract(NDI45_inv, biomasa_MAT),
                             NDVI_inv = extract(NDVI_inv, biomasa_MAT),
                             SAVI_inv = extract(SAVI_inv, biomasa_MAT),
                             TNDVI_inv = extract(TNDVI_inv, biomasa_MAT),
                             slope = extract(slope, biomasa_MAT),
                             aspect = extract(aspect, biomasa_MAT),
                             cnbl = extract(cnbl, biomasa_MAT),
                             cnd = extract(cnd, biomasa_MAT),
                             CI = extract(CI, biomasa_MAT),
                             LS_factor = extract(LS_factor, biomasa_MAT),
                             PlanCurv = extract(PlanCurv, biomasa_MAT),
                             ProfCurv = extract(ProfCurv, biomasa_MAT),
                             TWI = extract(TWI, biomasa_MAT),
                             
                             B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_MAT),
                             B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_MAT),
                             B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_MAT),
                             B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_MAT),
                             B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_MAT),
                             B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_MAT),
                             
                             B02_i_t_3_dis = extract(B02_inv_tex_3_dis, biomasa_MAT),
                             B02_i_t_3_mea = extract(B02_inv_tex_3_mea, biomasa_MAT),
                             B02_i_t_3_var = extract(B02_inv_tex_3_var, biomasa_MAT),
                             B02_v_t_3_dis = extract(B02_ver_tex_3_dis, biomasa_MAT),
                             B02_v_t_3_mea = extract(B02_ver_tex_3_mea, biomasa_MAT),
                             B02_v_t_3_var = extract(B02_ver_tex_3_var, biomasa_MAT),
                             
                             B03_i_t_3_dis = extract(B03_inv_tex_3_dis, biomasa_MAT),
                             B03_i_t_3_mea = extract(B03_inv_tex_3_mea, biomasa_MAT),
                             B03_i_t_3_var = extract(B03_inv_tex_3_var, biomasa_MAT),
                             B03_v_t_3_dis = extract(B03_ver_tex_3_dis, biomasa_MAT),
                             B03_v_t_3_mea = extract(B03_ver_tex_3_mea, biomasa_MAT),
                             B03_v_t_3_var = extract(B03_ver_tex_3_var, biomasa_MAT),
                             
                             B04_i_t_3_dis = extract(B04_inv_tex_3_dis, biomasa_MAT),
                             B04_i_t_3_mea = extract(B04_inv_tex_3_mea, biomasa_MAT),
                             B04_i_t_3_var = extract(B04_inv_tex_3_var, biomasa_MAT),
                             B04_v_t_3_dis = extract(B04_ver_tex_3_dis, biomasa_MAT),
                             B04_v_t_3_mea = extract(B04_ver_tex_3_mea, biomasa_MAT),
                             B04_v_t_3_var = extract(B04_ver_tex_3_var, biomasa_MAT),
                             
                             B05_i_t_3_dis = extract(B05_inv_tex_3_dis, biomasa_MAT),
                             B05_i_t_3_mea = extract(B05_inv_tex_3_mea, biomasa_MAT),
                             B05_i_t_3_var = extract(B05_inv_tex_3_var, biomasa_MAT),
                             B05_v_t_3_dis = extract(B05_ver_tex_3_dis, biomasa_MAT),
                             B05_v_t_3_mea = extract(B05_ver_tex_3_mea, biomasa_MAT),
                             B05_v_t_3_var = extract(B05_ver_tex_3_var, biomasa_MAT),
                             
                             B06_i_t_3_dis = extract(B06_inv_tex_3_dis, biomasa_MAT),
                             B06_i_t_3_mea = extract(B06_inv_tex_3_mea, biomasa_MAT),
                             B06_i_t_3_var = extract(B06_inv_tex_3_var, biomasa_MAT),
                             B06_v_t_3_dis = extract(B06_ver_tex_3_dis, biomasa_MAT),
                             B06_v_t_3_mea = extract(B06_ver_tex_3_mea, biomasa_MAT),
                             B06_v_t_3_var = extract(B06_ver_tex_3_var, biomasa_MAT),
                             
                             B07_i_t_3_dis = extract(B07_inv_tex_3_dis, biomasa_MAT),
                             B07_i_t_3_mea = extract(B07_inv_tex_3_mea, biomasa_MAT),
                             B07_i_t_3_var = extract(B07_inv_tex_3_var, biomasa_MAT),
                             B07_v_t_3_dis = extract(B07_ver_tex_3_dis, biomasa_MAT),
                             B07_v_t_3_mea = extract(B07_ver_tex_3_mea, biomasa_MAT),
                             B07_v_t_3_var = extract(B07_ver_tex_3_var, biomasa_MAT),
                             
                             B08a_i_t_3_dis = extract(B08a_inv_tex_3_dis, biomasa_MAT),
                             B08a_i_t_3_mea = extract(B08a_inv_tex_3_mea, biomasa_MAT),
                             B08a_i_t_3_var = extract(B08a_inv_tex_3_var, biomasa_MAT),
                             B08a_v_t_3_dis = extract(B08a_ver_tex_3_dis, biomasa_MAT),
                             B08a_v_t_3_mea = extract(B08a_ver_tex_3_mea, biomasa_MAT),
                             B08a_v_t_3_var = extract(B08a_ver_tex_3_var, biomasa_MAT),
                             
                             B11_i_t_3_dis = extract(B11_inv_tex_3_dis, biomasa_MAT),
                             B11_i_t_3_mea = extract(B11_inv_tex_3_mea, biomasa_MAT),
                             B11_i_t_3_var = extract(B11_inv_tex_3_var, biomasa_MAT),
                             B11_v_t_3_dis = extract(B11_ver_tex_3_dis, biomasa_MAT),
                             B11_v_t_3_mea = extract(B11_ver_tex_3_mea, biomasa_MAT),
                             B11_v_t_3_var = extract(B11_ver_tex_3_var, biomasa_MAT),
                             
                             B12_i_t_3_dis = extract(B12_inv_tex_3_dis, biomasa_MAT),
                             B12_i_t_3_mea = extract(B12_inv_tex_3_mea, biomasa_MAT),
                             B12_i_t_3_var = extract(B12_inv_tex_3_var, biomasa_MAT),
                             B12_v_t_3_dis = extract(B12_ver_tex_3_dis, biomasa_MAT),
                             B12_v_t_3_mea = extract(B12_ver_tex_3_mea, biomasa_MAT),
                             B12_v_t_3_var = extract(B12_ver_tex_3_var, biomasa_MAT),
                             
                             MDC_t_3_dis = extract(MDC_tex_3_dis, biomasa_MAT),
                             MDC_t_3_mea = extract(MDC_tex_3_mea, biomasa_MAT),
                             MDC_t_3_var = extract(MDC_tex_3_var, biomasa_MAT),
                             
                             DEM_t_3_dis = extract(DEM_tex_3_dis, biomasa_MAT),
                             DEM_t_3_mea = extract(DEM_tex_3_mea, biomasa_MAT),
                             DEM_t_3_var = extract(DEM_tex_3_var, biomasa_MAT),
                             
                             TX_t_3_dis = extract(TX_tex_3_dis, biomasa_MAT),
                             TX_t_3_mea = extract(TX_tex_3_mea, biomasa_MAT),
                             TX_t_3_var = extract(TX_tex_3_var, biomasa_MAT),
                             
                             # biopyhsical
                             
                             LAI_ver_t_3_dis = extract(LAI_ver_tex_3_dis, biomasa_MAT),
                             LAI_ver_t_3_mea = extract(LAI_ver_tex_3_mea, biomasa_MAT),
                             LAI_ver_t_3_var = extract(LAI_ver_tex_3_var, biomasa_MAT),
                             
                             Cab_ver_t_3_dis = extract(Cab_ver_tex_3_dis, biomasa_MAT),
                             Cab_ver_t_3_mea = extract(Cab_ver_tex_3_mea, biomasa_MAT),
                             Cab_ver_t_3_var = extract(Cab_ver_tex_3_var, biomasa_MAT),
                             
                             Cwc_ver_t_3_dis = extract(Cwc_ver_tex_3_dis, biomasa_MAT),
                             Cwc_ver_t_3_mea = extract(Cwc_ver_tex_3_mea, biomasa_MAT),
                             Cwc_ver_t_3_var = extract(Cwc_ver_tex_3_var, biomasa_MAT),
                             
                             FPAR_ver_t_3_dis = extract(FPAR_ver_tex_3_dis, biomasa_MAT),
                             FPAR_ver_t_3_mea = extract(FPAR_ver_tex_3_mea, biomasa_MAT),
                             FPAR_ver_t_3_var = extract(FPAR_ver_tex_3_var, biomasa_MAT),
                             
                             FVC_ver_t_3_dis = extract(FVC_ver_tex_3_dis, biomasa_MAT),
                             FVC_ver_t_3_mea = extract(FVC_ver_tex_3_mea, biomasa_MAT),
                             FVC_ver_t_3_var = extract(FVC_ver_tex_3_var, biomasa_MAT),
                             
                             
                             LAI_inv_t_3_dis = extract(LAI_inv_tex_3_dis, biomasa_MAT),
                             LAI_inv_t_3_mea = extract(LAI_inv_tex_3_mea, biomasa_MAT),
                             LAI_inv_t_3_var = extract(LAI_inv_tex_3_var, biomasa_MAT),
                             
                             Cab_inv_t_3_dis = extract(Cab_inv_tex_3_dis, biomasa_MAT),
                             Cab_inv_t_3_mea = extract(Cab_inv_tex_3_mea, biomasa_MAT),
                             Cab_inv_t_3_var = extract(Cab_inv_tex_3_var, biomasa_MAT),
                             
                             Cwc_inv_t_3_dis = extract(Cwc_inv_tex_3_dis, biomasa_MAT),
                             Cwc_inv_t_3_mea = extract(Cwc_inv_tex_3_mea, biomasa_MAT),
                             Cwc_inv_t_3_var = extract(Cwc_inv_tex_3_var, biomasa_MAT),
                             
                             FPAR_inv_t_3_dis = extract(FPAR_inv_tex_3_dis, biomasa_MAT),
                             FPAR_inv_t_3_mea = extract(FPAR_inv_tex_3_mea, biomasa_MAT),
                             FPAR_inv_t_3_var = extract(FPAR_inv_tex_3_var, biomasa_MAT),
                             
                             FVC_inv_t_3_dis = extract(FVC_inv_tex_3_dis, biomasa_MAT),
                             FVC_inv_t_3_mea = extract(FVC_inv_tex_3_mea, biomasa_MAT),
                             FVC_inv_t_3_var = extract(FVC_inv_tex_3_var, biomasa_MAT),
                             
                             # VIs
                             
                             GNDVI_ver_t_3_dis = extract(GNDVI_ver_tex_3_dis, biomasa_MAT),
                             GNDVI_ver_t_3_mea = extract(GNDVI_ver_tex_3_mea, biomasa_MAT),
                             GNDVI_ver_t_3_var= extract(GNDVI_ver_tex_3_var, biomasa_MAT),
                             
                             IRECI_ver_t_3_dis = extract(IRECI_ver_tex_3_dis, biomasa_MAT),
                             IRECI_ver_t_3_mea = extract(IRECI_ver_tex_3_mea, biomasa_MAT),
                             IRECI_ver_t_3_var = extract(IRECI_ver_tex_3_var, biomasa_MAT),
                             
                             NDI45_ver_t_3_dis = extract(NDI45_ver_tex_3_dis, biomasa_MAT),
                             NDI45_ver_t_3_mea = extract(NDI45_ver_tex_3_mea, biomasa_MAT),
                             NDI45_ver_t_3_var = extract(NDI45_ver_tex_3_var, biomasa_MAT),
                             
                             NDVI_ver_t_3_dis = extract(NDVI_ver_tex_3_dis, biomasa_MAT),
                             NDVI_ver_t_3_mea = extract(NDVI_ver_tex_3_mea, biomasa_MAT),
                             NDVI_ver_t_3_var = extract(NDVI_ver_tex_3_var, biomasa_MAT),
                             
                             SAVI_ver_t_3_dis = extract(SAVI_ver_tex_3_dis, biomasa_MAT),
                             SAVI_ver_t_3_mea = extract(SAVI_ver_tex_3_mea, biomasa_MAT),
                             SAVI_ver_t_3_var = extract(SAVI_ver_tex_3_var, biomasa_MAT),
                             
                             TNDVI_ver_t_3_dis = extract(TNDVI_ver_tex_3_dis, biomasa_MAT),
                             TNDVI_ver_t_3_mea = extract(TNDVI_ver_tex_3_mea, biomasa_MAT),
                             TNDVI_ver_t_3_var = extract(TNDVI_ver_tex_3_var, biomasa_MAT),
                             
                             GNDVI_inv_t_3_dis = extract(GNDVI_inv_tex_3_dis, biomasa_MAT),
                             GNDVI_inv_t_3_mea = extract(GNDVI_inv_tex_3_mea, biomasa_MAT),
                             GNDVI_inv_t_3_var= extract(GNDVI_inv_tex_3_var, biomasa_MAT),
                             
                             IRECI_inv_t_3_dis = extract(IRECI_inv_tex_3_dis, biomasa_MAT),
                             IRECI_inv_t_3_mea = extract(IRECI_inv_tex_3_mea, biomasa_MAT),
                             IRECI_inv_t_3_var = extract(IRECI_inv_tex_3_var, biomasa_MAT),
                             
                             NDI45_inv_t_3_dis = extract(NDI45_inv_tex_3_dis, biomasa_MAT),
                             NDI45_inv_t_3_mea = extract(NDI45_inv_tex_3_mea, biomasa_MAT),
                             NDI45_inv_t_3_var = extract(NDI45_inv_tex_3_var, biomasa_MAT),
                             
                             NDVI_inv_t_3_dis = extract(NDVI_inv_tex_3_dis, biomasa_MAT),
                             NDVI_inv_t_3_mea = extract(NDVI_inv_tex_3_mea, biomasa_MAT),
                             NDVI_inv_t_3_var = extract(NDVI_inv_tex_3_var, biomasa_MAT),
                             
                             SAVI_inv_t_3_dis = extract(SAVI_inv_tex_3_dis, biomasa_MAT),
                             SAVI_inv_t_3_mea = extract(SAVI_inv_tex_3_mea, biomasa_MAT),
                             SAVI_inv_t_3_var = extract(SAVI_inv_tex_3_var, biomasa_MAT),
                             
                             TNDVI_inv_t_3_dis = extract(TNDVI_inv_tex_3_dis, biomasa_MAT),
                             TNDVI_inv_t_3_mea = extract(TNDVI_inv_tex_3_mea, biomasa_MAT),
                             TNDVI_inv_t_3_var = extract(TNDVI_inv_tex_3_var, biomasa_MAT),
                             
                             # topographic variables
                             
                             slope_t_3_dis = extract(slope_tex_3_dis, biomasa_MAT),
                             slope_t_3_mea = extract(slope_tex_3_dis, biomasa_MAT),
                             slope_t_3_dis = extract(slope_tex_3_mea, biomasa_MAT),
                             
                             aspect_t_3_dis = extract(aspect_tex_3_dis, biomasa_MAT),
                             aspect_t_3_mea = extract(aspect_tex_3_mea, biomasa_MAT),
                             aspect_t_3_var = extract(aspect_tex_3_var, biomasa_MAT),
                             
                             cnbl_t_3_dis = extract(cnbl_tex_3_dis, biomasa_MAT),
                             cnbl_t_3_mea = extract(cnbl_tex_3_mea, biomasa_MAT),
                             cnbl_t_3_var = extract(cnbl_tex_3_var, biomasa_MAT),
                             
                             cnd_t_3_dis =  extract(cnd_tex_3_dis, biomasa_MAT),
                             cnd_t_3_mea=  extract(cnd_tex_3_mea, biomasa_MAT),
                             cnd_t_3_var =  extract(cnd_tex_3_var, biomasa_MAT),
                             
                             CI_t_3_dis = extract(CI_tex_3_dis, biomasa_MAT),
                             CI_t_3_mea = extract(CI_tex_3_mea, biomasa_MAT),
                             CI_t_3_var = extract(CI_tex_3_var, biomasa_MAT),
                             
                             LS_factor_t_3_dis = extract(LS_factor_tex_3_dis, biomasa_MAT),
                             LS_factor_t_3_mea = extract(LS_factor_tex_3_mea, biomasa_MAT),
                             LS_factor_t_3_var = extract(LS_factor_tex_3_var, biomasa_MAT),
                             
                             PlanC_t_3_dis = extract(PlanCurv_tex_3_dis, biomasa_MAT),
                             PlanC_t_3_mea = extract(PlanCurv_tex_3_mea, biomasa_MAT),
                             PlanC_t_3_var = extract(PlanCurv_tex_3_var, biomasa_MAT),
                             
                             ProfC_t_3_dis = extract(ProfCurv_tex_3_dis, biomasa_MAT),
                             ProfC_t_3_mea = extract(ProfCurv_tex_3_mea, biomasa_MAT),
                             ProfC_t_3_var = extract(ProfCurv_tex_3_var, biomasa_MAT),
                             
                             TWI_t_3_dis = extract(TWI_tex_3_dis, biomasa_MAT),
                             TWI_t_3_mea = extract(TWI_tex_3_mea, biomasa_MAT),
                             TWI_t_3_var = extract(TWI_tex_3_var, biomasa_MAT))

write.csv(biomasa_mat_df,'biomasa_mattoral_predictoras_f.csv')





############################
## Grasslands
############################

colnames(biomasa_prad_df)
head(biomasa_prad_df)


############
## RF

table(is.na(biomasa_prad_df))

# train random forest model using all predictors
rfm_pr <- randomForest(biomasa_prad_df[,3:216], biomasa_prad_df[,2], ntree=500, importance = T)
rfm_pr

# check model performance
plot(biomasa_prad_df[,2], rfm_pr$predicted, ylim=c(0,8), xlim=c(0,8))
abline(0,1)
text(biomasa_prad_df[,2], rfm_pr$predicted, biomasa_prad_df$parcela)

# check spearman and RMSE

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_wo_vsurf_pradera.txt")
cor(rfm_pr$predicted, biomasa_prad_df[,3], method="spearman")
RMSE(rfm_pr$predicted, biomasa_prad_df[,3])
sink()


#########
## VSURF


set.seed(34)
# run variable selection with VSURF
vrfm_pr <- VSURF(biomasa_prad_df[,3:216], biomasa_prad_df[,2], ntree=500, parallel = TRUE, ncores = 3)

setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_pr, file = "vsurf_prad.RData")
load("vsurf_prad.RData")

# check selected variables
vrfm_pr$varselect.interp
colnames(biomasa_prad_df)[vrfm_pr$varselect.interp+2]
vrfm_pr$varselect.pred
colnames(biomasa_prad_df)[vrfm_pr$varselect.pred+2]

# save selected variables
sink("/home/fabian/Fondecyt/5_outputs/3_sel_vars/pradera_sel_var.txt")
colnames(biomasa_prad_df)[vrfm_pr$varselect.interp+2]
colnames(biomasa_prad_df)[vrfm_pr$varselect.pred+2]
sink()


# train random forest model using selected variables
set.seed(5)
rfm2_pr <- randomForest(biomasa_prad_df[,vrfm_pr$varselect.pred+2], biomasa_prad_df[,2], ntree=500, importance = T)
rfm2_pr

summary(biomasa_prad_df[,2])

# save scatterplot with performance metrics
setwd("/home/fabian/Fondecyt/5_outputs/2_plots")
png(filename = "pradera_vsurf_sctter.png", width=1100, height=1100, res=250)

  # check results
  plot(biomasa_prad_df[,2], rfm2_pr$predicted, ylim=c(0,8), xlim=c(0,8), 
       ylab="Predicted Biomass Grassland [t/ha]", xlab="Observed Biomass Grassland [t/ha]")
  abline(0,1)
  # text(biomasa_prad_df[,3], rfm2_pr$predicted, biomasa_prad_df$parcela)
  
  # check spearman and RMSE
  pr_cor <- round(cor(rfm2_pr$predicted, biomasa_prad_df[,2], method="spearman"), 2)
  pr_RMSE <- round(RMSE(rfm2_pr$predicted, biomasa_prad_df[,2]),2)
  pr_nRMSE <- round(nrmse(rfm2_pr$predicted, biomasa_prad_df[,2], norm="maxmin"),2)

  text((8-0)*.75, (8-0)*.02, paste0("spearman cor. = ",pr_cor))
  text((8-0)*.75, (8-0)*.10, paste0("RMSE = ", pr_RMSE, " t/ha"))
  text((8-0)*.75, (8-0)*.18, paste0("nRMSE = ", pr_nRMSE, "%"))

dev.off()



### save performance metrics
setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_with_vsurf_pradera.txt")
pr_cor
pr_RMSE
sink()



#################################
## iterative RF with subsampling
#################################


# start subsampling
# for subsampling we use only the three predictors selected above with VSURF

# prepare raster stack for the two predictors

# stack the three predictors and get rid of NAs
rstack_prad <- stack(B12_ver,B5_inv)
rstack_prad[is.na(rstack_prad)] <- 99999

# convert raster stack to dataframe
df.rstack_prad <- as.data.frame(rstack_prad)

# make sure that the dataframe has the same column names
# as the data used in training the rf model
colnames(df.rstack_prad) <- colnames(biomasa_prad_df)[vrfm_pr$varselect.pred+2]
head(df.rstack_prad)

################################################
######### start iterative process here #########
################################################


# iterative process is splitted into two loops to save memory space

set.seed(12)


# start loop


for (i2 in 1:10){
  
  # create empty list to store the results
  results_prad <- list()
  results_prad_vec <- list()
  results_prad_cor <- list()
  
  for (i in 1:10){
  
    # get copy of one of the raster layers
    dummy_prad <- SAVI_ver
    # create random sample of the field data (80%)
    samp_prad <- sample(seq(1,nrow(biomasa_prad_df),1), round(nrow(biomasa_prad_df)*0.8))
    # train model based on the 80% field data
    rfm_it_prad <- randomForest(biomasa_prad_df[samp_prad,vrfm_pr$varselect.pred+2], biomasa_prad_df[samp_prad,2], ntree=500, importance = T)
    # predict model to the whole study area
    map_prad <- predict(rfm_it_prad, df.rstack_prad, na.rm=T)
    # predict model to hold out sample
    hor_prad <- predict(rfm_it_prad, biomasa_prad_df[-samp_prad,vrfm_pr$varselect.pred+2])
    # calculate correlation for hold out sample
    hor_prad_cor <- cor(hor_prad, biomasa_prad_df[-samp_prad,2], method="spearman")
    hor_prad_rmse <- RMSE(hor_prad, biomasa_prad_df[-samp_prad,2])
    # overwrite the raster dummy with the predicted values
    values(dummy_prad) <- map_prad
    # save results
    results_prad_vec[[i]] <- map_prad
    results_prad[[i]] <- dummy_prad
    results_prad_cor[[i]] <- c(hor_prad_cor, hor_prad_rmse)
    print(i)
  }
  
  setwd("/home/fabian/Fondecyt/5_outputs/5_maps")
  save(results_prad, file=paste0("results_iter_prad_",i2,".RData"))
  save(results_prad_vec, file=paste0("results_iter_prad_vec_", i2, ".RData"))
  save(results_prad_cor, file=paste0("results_iter_prad_cor_",i2,".RData"))
  
  rm(results_prad)
  rm(results_prad_vec)
  rm(results_prad_cor)
  
}




# plot map for first iteration
plot(results_prad[[1]])

# calculate average map
avgmap_prad <- do.call(mean, results_prad)
plot(avgmap_prad)

# calculate standard deviation for nrit iterations
# from vector data

df.nrit_prad <- do.call(cbind, results_prad_vec)
sd.nrit_prad <- rowSds(df.nrit_prad)
values(dummy_prad) <- sd.nrit_prad

# save results to raster files
writeRaster(dummy_prad, filename = "SD_pred_prad.tif", format="GTiff")
writeRaster(avgmap_prad, filename = "MEAN_pred_prad.tif", format="GTiff")


# apply vsurf bn model (all samples) to full area
map_all_samp_pr<- predict(rfm2_pr, df.rstack_prad)
outp_pr <- SAVI_ver
values(outp_pr) <- map_all_samp_pr
# save results

writeRaster(outp_pr, filename = "biomass_map_prad.tif", format="GTiff")




############################
## Shrublands
############################

# get rid of three outlier samples

biomasa_matorral_df2 <- biomasa_mat_df[-c(5,47,49),]

############
## RF

# train random forest model
colnames(biomasa_matorral_df2)
rfm_mat <- randomForest(biomasa_matorral_df2[,3:216], biomasa_matorral_df2[,2], ntree=500, importance = T)
rfm_mat

# check results
plot(biomasa_matorral_df2[,2], rfm_mat$predicted)
abline(0,1)
text(biomasa_matorral_df2[,2], rfm_mat$predicted, biomasa_matorral_df2$parcela)

# check spearman and RMSE
cor(rfm_mat$predicted, biomasa_matorral_df2[,2], method="spearman")
RMSE(rfm_mat$predicted, biomasa_matorral_df2[,2])

# save model performances without VSURF
sink("performance_wo_vsurf_matorral.txt")
cor(rfm_mat$predicted, biomasa_matorral_df2[,2], method="spearman")
RMSE(rfm_mat$predicted, biomasa_matorral_df2[,2])
sink()


#########
## VSURF

set.seed(12)
# run variable selection with VSURF
vrfm_mat <- VSURF(biomasa_matorral_df2[,3:216], biomasa_matorral_df2[,2], ntree=500, parallel = TRUE, ncores = 1)
# save vsurf object
setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_mat, file = "vsurf_mat.RData")
load("vsurf_mat.RData")

# check selected variables
vrfm_mat$varselect.pred
colnames(biomasa_matorral_df2)[vrfm_mat$varselect.pred+2]

# save info on selected variables
sink("/home/fabian/Fondecyt/5_outputs/3_sel_vars/matorral_sel_var.txt")
colnames(biomasa_matorral_df2)[vrfm_mat$varselect.interp+2]
colnames(biomasa_matorral_df2)[vrfm_mat$varselect.pred+2]
sink()




# train random forest model with selected variables
rfm_mat2 <- randomForest(biomasa_matorral_df2[,vrfm_mat$varselect.pred+2], biomasa_matorral_df2[,2], ntree=500, importance = T)
rfm_mat2

# check results
plot(biomasa_matorral_df2[,2], rfm_mat2$predicted)
abline(0,1)
text(biomasa_matorral_df2[,2], rfm_mat2$predicted, biomasa_mat_df$parcela[-c(5,47,49)])

# check spearman and RMSE
cor(rfm_mat2$predicted, biomasa_matorral_df2[,2], method="spearman")
RMSE(rfm_mat2$predicted, biomasa_matorral_df2[,2])

summary(biomasa_matorral_df2[,2])

# save scatter plot with performance metrics
setwd("/home/fabian/Fondecyt/5_outputs/2_plots")
png(filename = "matorral_vsurf_sctter2.png", width=1100, height=1100, res=250)

  # check results
  plot(biomasa_matorral_df2[,2], rfm_mat2$predicted, ylim=c(0,18), xlim=c(0,18), 
       ylab="Predicted Biomass Shrubland [t/ha]", xlab="Observed Biomass Shrubland [t/ha]")
  abline(0,1)
  # text(biomasa_prad_df[,3], rfm2_pr$predicted, biomasa_prad_df$parcela)
  
  # check spearman and RMSE
  mat_cor <- round(cor(rfm_mat2$predicted, biomasa_matorral_df2[,2], method="spearman"), 2)
  mat_RMSE <- round(RMSE(rfm_mat2$predicted, biomasa_matorral_df2[,2]),2)
  mat_nRMSE <- round(nrmse(rfm_mat2$predicted, biomasa_matorral_df2[,2], norm="maxmin"),2)
  
  text((18-0)*.75, (18-0)*.02, paste0("spearman cor. = ",mat_cor))
  text((18-0)*.75, (18-0)*.10, paste0("RMSE = ", mat_RMSE, " t/ha"))
  text((18-0)*.75, (18-0)*.18, paste0("nRMSE = ", mat_nRMSE, "%"))

dev.off()

# save performance metrics with VSURF
setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_with_vsurf_matorral.txt")
mat_cor
mat_RMSE
sink()

#################################
## iterative RF with subsampling
#################################


# start subsampling
# for subsampling we use only three predictors selected above with VSURF

# prepare raster stack for the three predictors
# resamples ProfCurv as it has a different spatial resolution
ProfCurv <- resample(ProfCurv, B2_ver)

# stack the three predictors and get rid of NAs
rstack <- stack(SAVI_ver,IRECI_ver,ProfCurv)
rstack[is.na(rstack)] <- 99999

# convert raster stack to dataframe
test <- as.data.frame(rstack)

# make sure that the dataframe has the same column names
# as the data used in training the rf model
colnames(test) <- colnames(biomasa_matorral_df2)[vrfm_mat$varselect.pred+2]
head(test)


################################################
######### start iterative process here #########
################################################

set.seed(12)

# create dummy raster to restore the geometric properties
dummy <- SAVI_ver

# start loop

for (i2 in 1:10){

  results <- list()
  results_vec <- list()
  results_cor <- list()
  
  for (i in 1:10){
  
    # get copy of one of the raster layers
    dummy <- SAVI_ver
    # create random sample of the field data (80%)
    samp <- sample(seq(1,nrow(biomasa_matorral_df2),1), round(nrow(biomasa_matorral_df2)*0.8))
    # train model based on the 80% field data
    rfm_it <- randomForest(biomasa_matorral_df2[samp,vrfm_mat$varselect.pred+2], biomasa_matorral_df2[samp,2], ntree=500, importance = T)
    # predict model to the whole study area
    map <- predict(rfm_it, test, na.rm=T)
    # predict model to hold out sample
    hor <- predict(rfm_it, biomasa_matorral_df2[-samp,vrfm_mat$varselect.pred+2])
    # calculate correlation for hold out sample
    hor_cor <- cor(hor, biomasa_matorral_df2[-samp,2], method="spearman")
    hor_rmse <- RMSE(hor, biomasa_matorral_df2[-samp,2])
    # overwrite the raster dummy with the predicted values
    values(dummy) <- map
    # save results
    results_vec[[i]] <- map
    results[[i]] <- dummy
    results_cor[[i]] <- c(hor_cor, hor_rmse)
    print(i)
  }
  
  setwd("/home/fabian/Fondecyt/5_outputs/5_maps")
  save(results, file=paste0("results_iter_mat_", i2, ".RData"))
  save(results_vec, file=paste0("results_iter_mat_vec_", i2, ".RData"))
  save(results_cor, file=paste0("results_iter_mat_cor_", i2, ".RData"))
    
}


# plot map for first iteration
plot(results[[1]])

# calculate average map
avgmap <- do.call(mean, results)
plot(avgmap)

# calculate standard deviation for nrit iterations
# from vector data

df.nrit <- do.call(cbind, results_vec)
sd.nrit <- rowSds(df.nrit)
values(dummy) <- sd.nrit

# save results to raster files
writeRaster(dummy, filename = "SD_pred_mat.tif", format="GTiff")
writeRaster(avgmap, filename = "MEAN_pred_mat.tif", format="GTiff")


# apply vsurf bn model (all samples) to full area
map_all_samp_mat<- predict(rfm_mat2, test)
outp_mat <- SAVI_ver
values(outp_mat) <- map_all_samp_mat
# save results
#setwd("E:/")
writeRaster(outp_mat, filename = "biomass_map_mat.tif", format="GTiff")





############################
## Native forests
############################

colnames(biomasa_bn_df)

table(is.na(biomasa_bn_df))
#biomasa_bn_df[is.na(biomasa_bn_df)] <- 99999

############
## RF

# train random forest model
rfm_bn <- randomForest(biomasa_bn_df[,3:216], biomasa_bn_df[,2], ntree=500, importance = T)
rfm_bn 

# check results

plot(biomasa_bn_df[,2], rfm_bn$predicted, ylim=c(0,400), xlim=c(0,400))
abline(0,1)
text(biomasa_bn_df[,2], rfm_bn$predicted, biomasa_bn_df$parcela)

# check spearman and RMSE

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_wo_vsurf_bn.txt")
cor(rfm_bn$predicted, biomasa_bn_df[,2], method="spearman")
RMSE(rfm_bn$predicted, biomasa_bn_df[,2])
sink()






#########
## VSURF

set.seed(23)
# run variable selection with vsurf
vrfm_bn <- VSURF(biomasa_bn_df[,3:216], biomasa_bn_df[,2], ntree=500, parallel = TRUE, ncores = 3)
setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_bn, file = "vsurf_bn.RData")
load("vsurf_bn.RData")

# check selected variables
vrfm_bn$varselect.pred
colnames(biomasa_bn_df)[vrfm_bn$varselect.pred+2]

# save info on selected variables
sink("/home/fabian/Fondecyt/5_outputs/3_sel_vars/bnsel_var.txt")
colnames(biomasa_bn_df)[vrfm_bn$varselect.interp+2]
colnames(biomasa_bn_df)[vrfm_bn$varselect.pred+2]
sink()


# train random forest model with selected variables
rfm2_bn <- randomForest(biomasa_bn_df[,vrfm_bn$varselect.pred+2], biomasa_bn_df[,2], ntree=500, importance = T)
rfm2_bn

# check results
plot(biomasa_bn_df[,2], rfm2_bn$predicted, ylim=c(0,400), xlim=c(0,400))
abline(0,1)
text(biomasa_bn_df[,2], rfm2_bn$predicted, biomasa_bn_df$parcela)

# check spearman and RMSE
cor(rfm2_bn$predicted, biomasa_bn_df[,2], method="spearman")
RMSE(rfm2_bn$predicted, biomasa_bn_df[,2])

summary(biomasa_bn_df[,2])

# prepare scatterplot with performance metrics
setwd("/home/fabian/Fondecyt/5_outputs/2_plots")
png(filename = "bn_vsurf_sctter.png", width=1100, height=1100, res=250)

  # check results
  plot(biomasa_bn_df[,2], rfm2_bn$predicted, ylim=c(0,400), xlim=c(0,400), 
       ylab="Predicted Biomass Native Forest [t/ha]", xlab="Observed Biomass Native Forest [t/ha]")
  abline(0,1)
  # text(biomasa_prad_df[,3], rfm2_pr$predicted, biomasa_prad_df$parcela)
  
  # check spearman and RMSE
  mat_cor <- round(cor(rfm2_bn$predicted, biomasa_bn_df[,2], method="spearman"), 2)
  mat_RMSE <- round(RMSE(rfm2_bn$predicted, biomasa_bn_df[,2]),2)
  mat_nRMSE <- round(nrmse(rfm2_bn$predicted, biomasa_bn_df[,2], norm="maxmin"),2)
  
  text((400-0)*.75, (400-0)*.02, paste("spearman cor. = ",mat_cor))
  text((400-0)*.75, (400-0)*.10, paste("RMSE = ", mat_RMSE, " t/ha"))
  text((400-0)*.75, (400-0)*.18, paste0("nRMSE = ", mat_nRMSE, "%"))
  
dev.off()

# save performance metrics with VSURF
setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_with_vsurf_bn.txt")
mat_cor
mat_RMSE
sink()

#################################
## iterative RF with subsampling
#################################


# start subsampling
# for subsampling we use only three predictors selected above with VSURF

# prepare raster stack for the two predictors

# stack the three predictors and get rid of NAs
MDC_m_res <- resample(MDC, B2_inv)
MDC_t_3_mea_res <- resample(MDC_tex_3_mea, B2_inv)
MDC_t_3_var_res <- resample(MDC_tex_3_var, B2_inv)

rstack_bn <- stack(MDC_m_res, MDC_t_3_mea_res, GNDVI_inv_tex_3_var, MDC_t_3_var_res, B11_inv)

#rstack_bn[is.na(rstack_bn)] <- 99999

# convert raster stack to dataframe
df.rstack_bn <- as.data.frame(rstack_bn)
df.rstack_bn[is.na(df.rstack_bn)] <- 99999

# make sure that the dataframe has the same column names
# as the data used in training the rf model
colnames(df.rstack_bn) <- colnames(biomasa_bn_df)[vrfm_bn$varselect.pred+2]
head(df.rstack_bn)

################################################
######### start iterative process here #########
################################################


set.seed(12)

dummy_bn <- B2_inv

# start loop

for (i2 in 1:10){
  
  # create empty list to store the results
  results_bn <- list()
  results_bn_vec <- list()
  results_bn_cor <- list()
  
  for (i in 1:10){
    
    # get copy of one of the raster layers
    dummy_bn <- SAVI_ver
    # create random sample of the field data (80%)
    samp_bn <- sample(seq(1,nrow(biomasa_bn_df),1), round(nrow(biomasa_bn_df)*0.8))
    # train model based on the 80% field data
    rfm_it_bn <- randomForest(biomasa_bn_df[samp_bn,vrfm_bn$varselect.pred+2], biomasa_bn_df[samp_bn,2], ntree=500, importance = T)
    # predict model to the whole study area
    map_bn <- predict(rfm_it_bn, df.rstack_bn, na.rm=T)
    # predict model to hold out sample
    hor_bn <- predict(rfm_it_bn, biomasa_bn_df[-samp_bn,vrfm_bn$varselect.pred+2])
    # calculate correlation for hold out sample
    hor_bn_cor <- cor(hor_bn, biomasa_bn_df[-samp_bn,2], method="spearman")
    hor_bn_rmse <- RMSE(hor_bn, biomasa_bn_df[-samp_bn,2])
    # overwrite the raster dummy with the predicted values
    values(dummy_bn) <- map_bn
    # save results
    results_bn_vec[[i]] <- map_bn
    results_bn[[i]] <- dummy_bn
    results_bn_cor[[i]] <- c(hor_bn_cor, hor_bn_rmse)
    print(i)
    
  }
  
  setwd("/home/fabian/Fondecyt/5_outputs/5_maps")
  save(results_bn, file=paste0("results_iter_bn_", i2,".RData"))
  save(results_bn_vec, file=paste0("results_iter_bn_vec_", i2, ".RData"))
  save(results_bn_cor, file=paste0("results_iter_bn_cor_", i2,".RData"))
  rm(results_bn)
  rm(results_bn_vec)
  rm(results_bn_cor)
  
}  



# plot map for first iteration
plot(results_bn[[1]])

# calculate average map
avgmap_bn <- do.call(mean, results_bn)
plot(avgmap_bn)

# calculate standard deviation for nrit iterations
# from vector data

df.nrit_bn <- do.call(cbind, results_bn_vec)
sd.nrit_bn <- rowSds(df.nrit_bn)
values(dummy_bn) <- sd.nrit_bn
plot(dummy_bn)

# save results to raster files
writeRaster(dummy_bn, filename = "SD_pred_bn.tif", format="GTiff")
writeRaster(avgmap_bn, filename = "MEAN_pred_bn.tif", format="GTiff")




# apply vsurf bn model (all samples) to full area
map_all_samp_bn<- predict(rfm2_bn, df.rstack_bn)
outp_bn <- SAVI_ver
values(outp_bn) <- map_all_samp_bn
# save results
#setwd("E:/")
writeRaster(outp_bn, filename = "biomass_map_bn.tif", format="GTiff")


############################
## Pine plantations
############################

colnames(biomasa_PINO_df)

table(is.na(biomasa_PINO_df))

#biomasa_PINO_df[is.na(biomasa_PINO_df)]<-99999
############
## RF

# train random forest model 
rfm_pin <- randomForest(biomasa_PINO_df[,3:216], biomasa_PINO_df[,2], ntree=500, importance = T)
rfm_pin

# check results
plot(biomasa_PINO_df[,2], rfm_pin$predicted, ylim=c(0,400), xlim=c(0,400))
abline(0,1)
text(biomasa_PINO_df[,2], rfm_pin$predicted, biomasa_PINO_df$parcela)

# check spearman and RMSE

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_wo_vsurf_pino.txt")
cor(rfm_pin$predicted, biomasa_PINO_df[,2], method="spearman")
RMSE(rfm_pin$predicted, biomasa_PINO_df[,2])
sink()


#########
## VSURF

set.seed(76)

# run variable selection with pine
vrfm_pin <- VSURF(biomasa_PINO_df[,3:216], biomasa_PINO_df[,2], ntree=500, parallel = TRUE, ncores = 3)
setwd("/home/fabian/Fondecyt/5_outputs/6_vsurf_objects")
#save(vrfm_pin, file = "vsurf_pin.RData")
load("vsurf_pin.RData")

# check selected variables
vrfm_pin$varselect.pred
colnames(biomasa_PINO_df)[vrfm_pin$varselect.pred+2]

sink("/home/fabian/Fondecyt/5_outputs/3_sel_vars/pino_sel_var.txt")
colnames(biomasa_PINO_df)[vrfm_pin$varselect.interp+2]
colnames(biomasa_PINO_df)[vrfm_pin$varselect.pred+2]
sink()


# train random forest model with selected variables
rfm2_pin <- randomForest(biomasa_PINO_df[,vrfm_pin$varselect.pred+2], biomasa_PINO_df[,2], ntree=500, importance = T)
rfm2_pin

# check results
plot(biomasa_PINO_df[,2], rfm2_pin$predicted, ylim=c(0,400), xlim=c(0,400))
abline(0,1)
text(biomasa_PINO_df[,2], rfm2_pin$predicted, biomasa_PINO_df$parcela)

# check spearman and RMSE
cor(rfm2_pin$predicted, biomasa_PINO_df[,2], method="spearman")
RMSE(rfm2_pin$predicted, biomasa_PINO_df[,2])


summary(biomasa_PINO_df[,2])

# save scatterplot with performance metrics

setwd("/home/fabian/Fondecyt/5_outputs/2_plots")
png(filename = "pine_vsurf_sctter.png", width=1100, height=1100, res=250)

  # check results
  plot(biomasa_PINO_df[,2], rfm2_pin$predicted, ylim=c(0,400), xlim=c(0,400), 
       ylab="Predicted Biomass Pine Plantation [t/ha]", xlab="Observed Biomass Pine Plantation [t/ha]")
  abline(0,1)
  # text(biomasa_prad_df[,3], rfm2_pr$predicted, biomasa_prad_df$parcela)
  
  # check spearman and RMSE
  mat_cor <- round(cor(rfm2_pin$predicted, biomasa_PINO_df[,2], method="spearman"), 2)
  mat_RMSE <- round(RMSE(rfm2_pin$predicted, biomasa_PINO_df[,2]),2)
  mat_nRMSE <- round(nrmse(rfm2_pin$predicted, biomasa_PINO_df[,2], norm="maxmin"),2)
  
  text((400-0)*.75, (400-0)*.02, paste("spearman cor. = ",mat_cor))
  text((400-0)*.75, (400-0)*.10, paste("RMSE = ", mat_RMSE, " t/ha"))
  text((400-0)*.75, (400-0)*.18, paste0("nRMSE = ", mat_nRMSE, "%"))

dev.off()


# save performance metrics with VSURF
setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
sink("performance_with_vsurf_pino.txt")
mat_cor
mat_RMSE
sink()


#################################
## iterative RF with subsampling
#################################


# start subsampling
# for subsampling we use only three predictors selected above with VSURF

# prepare raster stack for the two predictors

# stack the three predictors and get rid of NAs
TX_res_pin <- resample(TX, B11_inv)
rstack_pin <- stack(TX_res_pin, B11_ver, B6_ver)

rstack_pin[is.na(rstack_pin)] <- 99999

# convert raster stack to dataframe
df.rstack_pin <- as.data.frame(rstack_pin)

# make sure that the dataframe has the same column names
# as the data used in training the rf model
colnames(df.rstack_pin) <- colnames(biomasa_PINO_df)[vrfm_pin$varselect.pred+2]
head(df.rstack_pin)

################################################
######### start iterative process here #########
################################################


set.seed(12)


# start loop

for (i2 in 1:10){
  
  # create empty list to store the results
  results_pin <- list()
  results_pin_vec <- list()
  results_pin_cor <- list()
  
  for (i in 1:10){
    
    # get copy of one of the raster layers
    dummy_pin <- SAVI_ver
    # create random sample of the field data (80%)
    samp_pin <- sample(seq(1,nrow(biomasa_PINO_df),1), round(nrow(biomasa_PINO_df)*0.8))
    # train model based on the 80% field data
    rfm_it_pin <- randomForest(biomasa_PINO_df[samp_pin,vrfm_pin$varselect.pred+2], biomasa_PINO_df[samp_pin,2], ntree=500, importance = T)
    # predict model to the whole study area
    map_pin <- predict(rfm_it_pin, df.rstack_pin, na.rm=T)
    # predict model to hold out sample
    hor_pin <- predict(rfm_it_pin, biomasa_PINO_df[-samp_pin,vrfm_pin$varselect.pred+2])
    # calculate correlation for hold out sample
    hor_pin_cor <- cor(hor_pin, biomasa_PINO_df[-samp_pin,2], method="spearman")
    hor_pin_rmse <- RMSE(hor_pin, biomasa_PINO_df[-samp_pin,2])
    # overwrite the raster dummy with the predicted values
    values(dummy_pin) <- map_pin
    # save results
    results_pin_vec[[i]] <- map_pin
    results_pin[[i]] <- dummy_pin
    results_pin_cor[[i]] <- c(hor_pin_cor, hor_pin_rmse)
    print(i)
    
  }
  
  setwd("/home/fabian/Fondecyt/5_outputs/5_maps")
  save(results_pin, file=paste0("results_iter_pin_", i2, ".RData"))
  save(results_pin_vec, file=paste0("results_iter_pin_vec_", i2, ".RData"))
  save(results_pin_cor, file=paste0("results_iter_pin_cor_", i2, ".RData"))
  
  
  
}

# plot map for first iteration
plot(results_pin[[1]])

# calculate average map
avgmap_pin <- do.call(mean, results_pin)
plot(avgmap_pin)

# calculate standard deviation for nrit iterations
# from vector data

df.nrit_pin <- do.call(cbind, results_pin_vec)
sd.nrit_pin <- rowSds(df.nrit_pin)
values(dummy_pin) <- sd.nrit_pin

# save results to raster files
writeRaster(dummy_pin, filename = "SD_pred_pin.tif", format="GTiff")
writeRaster(avgmap_pin, filename = "MEAN_pred_pin.tif", format="GTiff")



# apply vsurf pine model (all samples) to full area
map_all_samp_pine <- predict(rfm2_pin, df.rstack_pin)
outp_pine <- SAVI_ver
values(outp_pine) <- map_all_samp_pine
# save results
#setwd("E:/")
writeRaster(outp_pine, filename = "biomass_map_pine.tif", format="GTiff")
