#GenerateVegMask.R
#Generates a vegetation mask for each species based on the table of mean
#probability of occurrence from GenerateVegTable.R
#
##Arguments:
# lc.table(data frame): output table from GenerateVegTable.R
# lc.path(string): Path to corine land cover level 3 grids (one by each land cover)
# threshold(numeric): threshold probability to consider any given land cover as suitable
# out.path(string): Path to folder where rasters will be saved

##Returns:
# A RasterLayer per species depicting suitable land cover
#
##Example:
#lc.table <- read.csv("C:/Workspace/VegTable.csv",as.is = T)
#lc.path <- "D:/Datos/coberturas_corine/BMExtent"
#threshold <- 0.5
#out.path <-"C:/Workspace"
#GenerateVegMask(lc.table, lc.path, threshold, out.path)

GenerateVegMask <- function(lc.table, lc.path, threshold, out.path){
  library(raster)
  lc.table <- lc.table[lc.table$Promedio>=threshold, ]
  sp.list<-unique(lc.table$Especie)
  blank.raster <- raster(paste0(lc.path,"/lc_2"))
  blank.raster[] <- 0
  for(i in 1:length(sp.list)){
    sub.table <- na.omit(lc.table[lc.table$Especie==sp.list[i], ])
    out.raster <- blank.raster
    for (j in 1:nrow(sub.table)){
      in.raster <- raster(paste0(lc.path, "/lc_",sub.table$IDShape[j]))
      out.raster <- out.raster + in.raster
    }
    out.raster[out.raster>1] <- 1 
    writeRaster(out.raster,paste0(out.path, "/", sp.list[i], ".tif"))
  }
}