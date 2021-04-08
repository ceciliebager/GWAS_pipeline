library(RMySQL)

# connect to PERF database
mydb <- dbConnect(MySQL(), user='cba', password='123Nordic', host="10.1.0.149", port = 3306)
data <- dbSendQuery(mydb, paste('SELECT PF, trunk_peripheral_fat_ratio_norm FROM perf1.dxa_wholebody_normalized'))
data_dxa <- fetch(data, n=-1)

mydb <- dbConnect(MySQL(), user='cba', password='123Nordic', host="10.1.0.149", port = 3306)
data1 <- dbSendQuery(mydb, paste('SELECT PF, BMI, baseline_age FROM perf1.vital'))
data_vital <- fetch(data1, n=-1)

# merge bio data
df <- merge(data_vital, data_dxa, by='PF')

# load PCs

PCs <- read.table('/mnt/storage/to_backup/results/eigenstratPCA/PCA_perf_maf1pct_feb2020.pca.evec')
PCs$PF <- apply(as.matrix(PCs$V1), 1, function(x) {unlist(strsplit(x, ':'))[2]})
head(PCs$PF)
colnames(PCs)[2:11] <- paste0('PC', 1:10)
head(PCs)

df_cba <- merge(PCs[,c('PF', 'PC1', 'PC2', 'PC3')], df, by='PF')
head(df_cba)

# tab separated data file
write.table(df_cba, '/mnt/development/VariableSelection/GWAS_cba/data_central_obesity.tsv', sep = '\t', row.names = FALSE)
