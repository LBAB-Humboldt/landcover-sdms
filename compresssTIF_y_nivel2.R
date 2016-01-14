#Compress tif files. 

flt2int<-function(raster.file,out.folder){
  library(raster)
  library(rgdal)
  in.raster <- raster(raster.file)
  writeRaster(in.raster,
              paste0(out.folder,"/",raster.file),
              datatype="INT1U")}

#BM Folder
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/BM")
raster.list<-list.files(getwd(),"*.tif$")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, flt2int,
                 out.folder="/home/cas/Jorge/Modelos/27112015/ValidationTab/BM/TIF")
sfStop()

#Inductivo Folder
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo")
raster.list<-list.files(getwd(),"*.tif$")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, flt2int,
                 out.folder="/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo/TIF")
sfStop()

#BRT Folder
setwd("/home/cas/Jorge/Modelos/27112015/BRT")
raster.list<-list.files("/home/cas/Jorge/Modelos/27112015/BRT/PNG","*.png$")
raster.list<-sub(".png",".tif",raster.list)
dir.create("/home/cas/Jorge/Modelos/27112015/BRT/TIF")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, flt2int,
                 out.folder="/home/cas/Jorge/Modelos/27112015/BRT/TIF")
sfStop()

#Maxent Folder
setwd("/home/cas/Jorge/Modelos/27112015/Maxent")
raster.list<-list.files("/home/cas/Jorge/Modelos/27112015/Maxent/PNG","*.png$")
raster.list<-sub(".png",".tif",raster.list)
dir.create("/home/cas/Jorge/Modelos/27112015/Maxent/TIF")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, flt2int,
                 out.folder="/home/cas/Jorge/Modelos/27112015/Maxent/TIF")
sfStop()

#Bioclim Folder
setwd("/home/cas/Jorge/Modelos/27112015/bioclim")
raster.list<-list.files("/home/cas/Jorge/Modelos/27112015/bioclim/PNG","*.png$")
raster.list<-sub(".png",".tif",raster.list)
dir.create("/home/cas/Jorge/Modelos/27112015/bioclim/TIF")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, flt2int,
                 out.folder="/home/cas/Jorge/Modelos/27112015/bioclim/TIF")
sfStop()

#Move CSV files
csv.list<-list.files("/home/cas/Jorge/Modelos/27112015/bioclim","*.csv$")
csv.list<-unique(sub("evaluation_bc","bc",csv.list))
new.name<-sub("_bc","",csv.list)
file.copy(csv.list,paste0("/home/cas/Jorge/Modelos/27112015/CSV/",new.name))

#Nivel 2
#BM
sp.names <- sub(".tif","",list.files("/home/cas/Jorge/Modelos/27112015/Nivel2/sp_masks","*.tif$"))
n2rasters<-function(sp.name, mask.folder, sp.folder, out.folder, suffix){
  library(raster)
  library(rgdal)
  raster.file<-paste0(sp.folder,"/",sp.name,suffix)
  if(file.exists(raster.file)){
    in.raster <- raster(raster.file)
    mask.raster <- raster(paste0(mask.folder,"/", sp.name,".tif"))
    in.raster <- crop(in.raster, mask.raster)
    extent(in.raster) <- extent(mask.raster)
    n2.raster <- (in.raster * mask.raster) >= 0.5
    writeRaster(n2.raster,paste0(out.folder,"/",sp.name, suffix),datatype="INT1U")
  }
}

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.names, 
                 n2rasters,
                 mask.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/sp_masks",
                 sp.folder="/home/cas/Jorge/Modelos/27112015/ValidationTab/BM",
                 out.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/BM",
                 suffix="_bm.tif")
sfStop()

#Deductivo
sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.names, 
                 n2rasters,
                 mask.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/sp_masks",
                 sp.folder="/home/cas/Jorge/Modelos/27112015/IUCN",
                 out.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Deductivo",
                 suffix=".tif")
sfStop()

#Inductivo
sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(sp.names, 
                 n2rasters,
                 mask.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/sp_masks",
                 sp.folder="/home/cas/Jorge/Modelos/27112015/ValidationTab/Inductivo",
                 out.folder="/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Inductivo",
                 suffix="_lba.tif")
sfStop()


##Convert2PNG
#BM
raster.list <- list.files("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/BM","*.tif")
setwd("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/BM")
col.pal = rgb(21,115,97,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Deductivo
raster.list <- list.files("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Deductivo","*.tif")
setwd("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Deductivo")
col.pal = rgb(21,115,97,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Inductivo
raster.list <- list.files("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Inductivo","*.tif")
setwd("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Inductivo")
col.pal = rgb(21,115,97,maxColorValue=255)
load("~/Jorge/params.RData")

sfInit(parallel=T,cpus=16)#Initialize nodes
sfExportAll() #Export vars to all the nodes
sfClusterSetupRNG()
sfClusterApplyLB(raster.list, convert2PNG, in.folder=getwd(), 
                 col.pal=col.pal, add.trans=TRUE, params=params)
sfStop()

#Rename IUCN files
setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Deductivo/PNG")
pngs<-list.files(getwd(),"*.png")
new.pngs <- paste0(sub(".png","",pngs),"_iucn.png")
file.rename(pngs,new.pngs)

setwd("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Deductivo/PNG")
pngs<-list.files(getwd(),"*.png")
new.pngs <- paste0(sub(".png","",pngs),"_iucn.png")
file.rename(pngs,new.pngs)

setwd("/home/cas/Jorge/Modelos/27112015/ValidationTab/Deductivo/thumb")
pngs<-list.files(getwd(),"*.png")
new.pngs <- paste0(sub("_thumb.png","",pngs),"_iucn_thumb.png")
file.rename(pngs,new.pngs)

setwd("/home/cas/Jorge/Modelos/27112015/Nivel2/ValidationTab/Deductivo/thumb")
pngs<-list.files(getwd(),"*.png")
new.pngs <- paste0(sub("_thumb.png","",pngs),"_iucn_thumb.png")
file.rename(pngs,new.pngs)

