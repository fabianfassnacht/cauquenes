load("/home/fabian/Fondecyt/5_outputs/4_performance/res_iter_perf_bn.RData")
load("/home/fabian/Fondecyt/5_outputs/4_performance/res_iter_perf_prad.RData")
load("/home/fabian/Fondecyt/5_outputs/4_performance/res_iter_perf_pin.RData")
load("/home/fabian/Fondecyt/5_outputs/4_performance/res_iter_perf_mat.RData")

setwd("/home/fabian/Fondecyt/5_outputs/4_performance")
# bottom, left, top, right
png(width=2000, height = 1400, filename = "iter_validation.png", res=300)
par(mfrow=c(1,2), mar=c(4,2,1.5,1), oma=c(3,1,1,1))
boxplot(res_prad_vec[,1],res_mat_vec[,1],res_bn_vec[,1],res_pin_vec[,1],
        main = "spearman correlation", cex.axis=1.3)
axis(1, at=c(1:4), labels=c("Grassl.","Shrubl.","Nat. For.","Pine Plant."), 
     las=2, cex.axis=1.3)
box()
boxplot(res_prad_vec[,3],res_mat_vec[,3],res_bn_vec[,3],res_pin_vec[,3],
        main = "nRMSE [%]", cex.axis=1.3)
axis(1, at=c(1:4), labels=c("Grassl.","Shrubl.","Nat. For.","Pine Plant."), 
     las=2, cex.axis=1.3)
box()
dev.off()


summary(res_prad_vec)
