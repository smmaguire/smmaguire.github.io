#makeJSON: 
#need and edgeList as well as a vertex 
#attributes list with unique IDS
#need to add something that goes through each day and rbinds them together
#going to get an example working with just one day first.

load("/Users/seanmaguire/Desktop/alex_social_networks/refactoredCode.RDATA")
makeJSON<-function(adjMat,v.attr,fileout="out.json"){
  lapply(c('jsonlite','igraph','dplyr'),require,character.only=T)
  g1<-graph.adjacency(adjMat,weighted=TRUE,diag=FALSE,mode="directed")
  EL<-as.data.frame(get.edgelist(g1))
  EL$weight<-get.edge.attribute(g1,"weight")
  names(EL)[1:2]<-c("source","target")
  names(v.attr)[1]<-"id"
  degreeDF<-data.frame(dout=degree(g1,mode="out"),
               din=degree(g1,mode="in"))
  degreeDF$id<-as.factor(rownames(degreeDF))
  v.attr<-dplyr::inner_join(v.attr,degreeDF,by='id')
  netJson<-toJSON(list("nodes"=v.attr,"links"=EL),pretty=TRUE)
  cat(netJson,file=fileout)
}

for(day in 1:7){
makeJSON(adjMat=groupA[day,,],v.attr=attr_A,fileout=paste0("/Users/seanmaguire/Desktop/d3/interactive_cichlid_network/data/","groupA","_","day",day,".json"))
}
for(day in 1:7){
  makeJSON(adjMat=groupB[day,,],v.attr=attr_B,fileout=paste0("/Users/seanmaguire/Desktop/d3/interactive_cichlid_network/data/","groupB","_","day",day,".json"))
}
for(day in 1:7){
  makeJSON(adjMat=groupC[day,,],v.attr=attr_C,fileout=paste0("/Users/seanmaguire/Desktop/d3/interactive_cichlid_network/data/","groupC","_","day",day,".json"))
}