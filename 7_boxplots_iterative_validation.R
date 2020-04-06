## R-Script - create violin boxplots 
## author: Javier Lopatin
## mail: javier.lopatin@gmail.com
## Manuscript: Using Multi-Sensor Data to Derive a Landscape-Level Biomass Map Covering Multiple Vegetation Types
## last changes: 06.04.2020
##

# load packages
require(yarrr)

# set directory
home <- '/home/javier/Documents/Conicyt_Mauro/Fabian-paper'
setwd(home)

# load raw data
load(paste0(home, "/4_performance/res_iter_perf_bn.RData"))

# define colors
col = c('#a6cee3','#1f78b4','#b2df8a','#33a02c', 'grey')

# prepare data in dataframe
r_data <- data.frame(res_prad_vec[,1],res_mat_vec[,1],res_pin_vec[,1],res_bn_vec[,1])
r_data <- cbind(r_data, rowMeans(r_data))
names(r_data) <- c("Grassl.","Shrubl.","Nat. For.","Pine Plant.", "Landscape")

nrmse_data <- data.frame(res_prad_vec[,3],res_mat_vec[,3],res_pin_vec[,3],res_bn_vec[,3])
nrmse_data <- cbind(nrmse_data, rowMeans(nrmse_data))
names(nrmse_data) <- c("Grassl.","Shrubl.","Nat. For.","Pine Plant.", "Landscape")
 
# bottom, left, top, right
# plot boxplots to file
png(width=2000, height = 1400, filename = "iter_validation2.png", res=300)
par(mfrow=c(1,2), mar=c(4,2,1.5,1), oma=c(3,1,1,1))
pirateplot(data=r_data, main="spearman correlation", pal = col, theme = 3,
           quant = c(.1, .9), quant.col = "black", cex.axis=1.3)

pirateplot(data=nrmse_data, main="nRMSE [%]", pal = col, theme = 3,
           quant = c(.1, .9), quant.col = "black", cex.axis=1.3)
dev.off()