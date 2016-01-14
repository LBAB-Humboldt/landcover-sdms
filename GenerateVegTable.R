#GenerateVegTable.R
#Generates a consolidated table of species' average probability of occurrence 
#in suitable level 3 land covers as informed by experts in BioModelos.

##Arguments:
# in.table(string): Path to "Variables Ecológicas" table from BioModelos. Must have
#                   fields Especie, Variable and Promedio.
# code.table(string): Path to BioModelos2CLC table, which contains the mapping of
#                     codes from BioModelos to Corine Land Cover level 3.

##Returns:
# Data frame of mean probability of occurrence by landcover by species.

##Example:
#in.table<-read.csv("C:/Modelos/Nivel2/VariablesEcologicas.csv")
#code.table<-read.csv("C:/Modelos/Nivel2/BioModelos2CLC.csv")
#result <- GenerateVegTable(in.table, code.table)


GenerateVegTable<-function(in.table,code.table){
  library(plyr)
  #Expand table from level 2 to level 3
  lc.levels <- code.table$Nivel[match(in.table$Variable, code.table$IDBioModelos)]
  level2.table <- in.table[which(lc.levels==2), ]  
  
  expand.l2.table <- data.frame()
  for (i in 1:nrow(level2.table)){
    tmp.table <- cbind(level2.table[i,], code.table[code.table$IDBioModelos==level2.table$Variable[i],2:4])
    expand.l2.table <- rbind(expand.l2.table, tmp.table)
  }
  
  level3.table <- in.table[which(lc.levels==3), ]   
  level3.table <- cbind(level3.table, 
        code.table[match(level3.table$Variable, code.table$IDBioModelos), 2:4])
  level3.table <- rbind(level3.table, expand.l2.table)
  
  #Compute average by species by landcover
  avg.by.code <- ddply(level3.table[ ,c("Especie", "IDShape", "Promedio")], .(Especie, IDShape), summarise, Promedio=mean(Promedio))
  code.table.l3 <- code.table[code.table$Nivel==3, ]
  avg.by.code <- cbind(Especie=avg.by.code[, 1],
                       Nombre.Cobertura=code.table.l3$Nombre.Cobertura[match(avg.by.code$IDShape, code.table.l3$IDShape)],
                       avg.by.code[,2:3])
  return(avg.by.code)
}