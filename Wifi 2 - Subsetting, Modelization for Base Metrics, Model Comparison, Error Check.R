### -------------------- Wifi Locationing -------------------- ###
### ------------------- by Alican Tana�an -------------------- ###
### ---- Version 2: Subsetting, Modelization, Error Check ---- ###

### ---- Libraries ----
if(require("pacman") == "FALSE"){
  install.packages("pacman")
}
p_load(shiny, shinydashboard, dplyr, ggplot2, plotly, lubridate,
       naniar, devtools, corrplot, GGally, caret, tidyverse, e1071,
       kernlab, randomForest, gridExtra, caTools)

### ---- Import Wifi Training and Validation Data ----
WifiTrainingData <- readRDS("CleanWifiTrainData.rds")

WifiValidationData <- read.csv("WifivalidationData.csv")

### ---- Preprocessing ----
## Create a data frame for WAPS and rest of the VARIABLES
WAPStrain <- WifiTrainingData[,1:520]

VARIABLEStrain <- WifiTrainingData[, 521:529]

WAPSvalid <- WifiValidationData[,1:520]

VARIABLESvalid <- WifiValidationData[, 521:529]

## Checking correlations
ggcorr(VARIABLEStrain, label = T)

## Revaluation of WAPS with poor signal
## Train
WAPStrain[WAPStrain < -90] <- -105

## Check interval of variance, mean and median of columns to eliminate 
wapsdata <- data.frame(variance = apply(WAPStrain, 2, var),
                       mean = apply(WAPStrain, 2, mean),
                       median = apply(WAPStrain, 2, median))
summary(wapsdata)

## Define poor signal waps and remove them from the data
PoorWAPStrainCol <- apply(WAPStrain, 2, var) <= 0.05

PoorWAPStrainRow <- apply(WAPStrain, 1, var) <= 0.05

GoodWAPStrain <- WAPStrain[!PoorWAPStrainRow,
                           !PoorWAPStrainCol]

## Validation
WAPSvalid[WAPSvalid == 100] <- -105
WAPSvalid[WAPSvalid < -90] <- -105 

validwapsdata <- data.frame(variance = apply(WAPSvalid, 2, var),
                            mean = apply(WAPSvalid, 2, mean),
                            median = apply(WAPSvalid, 2, median))
summary(validwapsdata)

PoorWAPSvalidCol <- apply(WAPSvalid, 2, var) == 0

PoorWAPSvalidRow <- apply(WAPSvalid, 1, var) == 0

GoodWAPSvalid <- WAPSvalid[!PoorWAPSvalidRow,
                           !PoorWAPSvalidCol]

## Equalizing the column amount in both WAPS data sets
WAPStrain2 <- GoodWAPStrain[, which(colnames(GoodWAPStrain) %in%
                                      colnames(GoodWAPSvalid))]

WAPSvalid2 <- GoodWAPSvalid[, which(colnames(GoodWAPSvalid) %in% 
                                      colnames(GoodWAPStrain))]

## Equalizing the row amount in both VARIABLE data sets
VARIABLEStrain2 <- VARIABLEStrain[!PoorWAPStrainRow, ]

VARIABLESvalid2 <- VARIABLESvalid[!PoorWAPSvalidRow, ]

## Combining the WAPS and VARIABLES data
WifiTrainingData <- cbind(WAPStrain2, VARIABLEStrain2)

WifiValidationData <- cbind(WAPSvalid2, VARIABLESvalid2)

### ---- Subsetting ----
set.seed(999)
## Training Data
# Building 0
WifiTrainingData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), LONGITUDE) -> Build0Long

SampleBuild0Long <- Build0Long[sample(1:nrow(Build0Long), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), LATITUDE) -> Build0Lat

SampleBuild0Lat <- Build0Lat[sample(1:nrow(Build0Lat), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), FLOOR) -> Build0Floor

SampleBuild0Floor <- Build0Floor[sample(1:nrow(Build0Floor), 2000, replace = F),]
SampleBuild0Floor$FLOOR <- as.factor(SampleBuild0Floor$FLOOR)

# Building 1
WifiTrainingData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), LONGITUDE) -> Build1Long

SampleBuild1Long <- Build1Long[sample(1:nrow(Build1Long), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), LATITUDE) -> Build1Lat

SampleBuild1Lat <- Build1Lat[sample(1:nrow(Build1Lat), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), FLOOR) -> Build1Floor

SampleBuild1Floor <- Build1Floor[sample(1:nrow(Build1Floor), 2000, replace = F),]
SampleBuild1Floor$FLOOR <- as.factor(SampleBuild1Floor$FLOOR)

# Building 2
WifiTrainingData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), LONGITUDE) -> Build2Long

SampleBuild2Long <- Build2Long[sample(1:nrow(Build2Long), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), LATITUDE) -> Build2Lat

SampleBuild2Lat <- Build2Lat[sample(1:nrow(Build2Lat), 2000, replace = F),]

WifiTrainingData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), FLOOR) -> Build2Floor

SampleBuild2Floor <- Build2Floor[sample(1:nrow(Build2Floor), 2000, replace = F),]
SampleBuild2Floor$FLOOR <- as.factor(SampleBuild2Floor$FLOOR)

## Validation Data
# Building 0
WifiValidationData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), LONGITUDE) -> VBuild0Long

WifiValidationData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), LATITUDE) -> VBuild0Lat

WifiValidationData %>% 
  filter(BUILDINGID == 0) %>%
  select(starts_with("WAP"), FLOOR) -> VBuild0Floor
VBuild0Floor$FLOOR <- as.factor(VBuild0Floor$FLOOR)

# Building 1
WifiValidationData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), LONGITUDE) -> VBuild1Long

WifiValidationData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), LATITUDE) -> VBuild1Lat

WifiValidationData %>% 
  filter(BUILDINGID == 1) %>%
  select(starts_with("WAP"), FLOOR) -> VBuild1Floor
VBuild1Floor$FLOOR <- as.factor(VBuild1Floor$FLOOR)

# Building 2
WifiValidationData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), LONGITUDE) -> VBuild2Long

WifiValidationData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), LATITUDE) -> VBuild2Lat

WifiValidationData %>% 
  filter(BUILDINGID == 2) %>%
  select(starts_with("WAP"), FLOOR) -> VBuild2Floor
VBuild2Floor$FLOOR <- as.factor(VBuild2Floor$FLOOR)

### ---- kNN Modelization ----
set.seed(1001)
# Building 0 Longitude
kNN0Long <- train(LONGITUDE ~ ., 
                  SampleBuild0Long,
                  method = "knn",
                  trControl = trainControl(method = "cv",
                                           number = 5),
                  preProcess = "zv")

predkNN0Long <- predict(kNN0Long, VBuild0Long)

postResample(predkNN0Long, VBuild0Long$LONGITUDE) -> kNN0LongMetrics
kNN0LongMetrics

# Building 0 Latitude
kNN0Lat <- train(LATITUDE ~ ., 
                  SampleBuild0Lat,
                  method = "knn",
                  trControl = trainControl(method = "cv",
                                           number = 5),
                  preProcess = "zv")

predkNN0Lat <- predict(kNN0Lat, VBuild0Lat)

postResample(predkNN0Lat, VBuild0Lat$LATITUDE) -> kNN0LatMetrics
kNN0LatMetrics

# Building 0 Floor
kNN0Floor <- train(FLOOR ~ ., 
                   SampleBuild0Floor,
                   method = "knn",
                   trControl = trainControl(method = "cv",
                                            number = 5),
                   preProcess = "zv")

predkNN0Floor <- predict(kNN0Floor, VBuild0Floor)

postResample(predkNN0Floor, VBuild0Floor$FLOOR) -> kNN0FloorMetrics
kNN0FloorMetrics

# Building 1 Longitude
kNN1Long <- train(LONGITUDE ~ ., 
                  SampleBuild1Long,
                  method = "knn",
                  trControl = trainControl(method = "cv",
                                           number = 5),
                  preProcess = "zv")

predkNN1Long <- predict(kNN1Long, VBuild1Long)

postResample(predkNN1Long, VBuild1Long$LONGITUDE) -> kNN1LongMetrics
kNN1LongMetrics

# Building 1 Latitude
kNN1Lat <- train(LATITUDE ~ ., 
                 SampleBuild1Lat,
                 method = "knn",
                 trControl = trainControl(method = "cv",
                                          number = 5),
                 preProcess = "zv")

predkNN1Lat <- predict(kNN1Lat, VBuild1Lat)

postResample(predkNN1Lat, VBuild1Lat$LATITUDE) -> kNN1LatMetrics
kNN1LatMetrics

# Building 1 Floor
kNN1Floor <- train(FLOOR ~ ., 
                   SampleBuild0Floor,
                   method = "knn",
                   trControl = trainControl(method = "cv",
                                            number = 5),
                   preProcess = "zv")

predkNN1Floor <- predict(kNN1Floor, VBuild1Floor)

postResample(predkNN1Floor, VBuild1Floor$FLOOR) -> kNN1FloorMetrics
kNN1FloorMetrics

# Building 2 Longitude
kNN2Long <- train(LONGITUDE ~ ., 
                  SampleBuild2Long,
                  method = "knn",
                  trControl = trainControl(method = "cv",
                                           number = 5),
                  preProcess = "zv")

predkNN2Long <- predict(kNN2Long, VBuild2Long)

postResample(predkNN2Long, VBuild2Long$LONGITUDE) -> kNN2LongMetrics
kNN2LongMetrics

# Building 2 Latitude
kNN2Lat <- train(LATITUDE ~ ., 
                 SampleBuild2Lat,
                 method = "knn",
                 trControl = trainControl(method = "cv",
                                          number = 5),
                 preProcess = "zv")

predkNN2Lat <- predict(kNN2Lat, VBuild2Lat)

postResample(predkNN2Lat, VBuild2Lat$LATITUDE) -> kNN2LatMetrics
kNN2LatMetrics

# Building 2 Floor
kNN2Floor <- train(FLOOR ~ ., 
                   SampleBuild2Floor,
                   method = "knn",
                   trControl = trainControl(method = "cv",
                                            number = 5),
                   preProcess = "zv")

predkNN2Floor <- predict(kNN2Floor, VBuild2Floor)

postResample(predkNN2Floor, VBuild2Floor$FLOOR) -> kNN2FloorMetrics
kNN2FloorMetrics

### ---- SVM Modelization ----
set.seed(1002)
# Building 0 Longitude
SVM0Long <- train(LONGITUDE ~ ., 
                  SampleBuild0Long,
                  method = "svmLinear",
                  trControl = trainControl(method = "repeatedcv", 
                                           number = 5, 
                                           repeats = 2),
                  tuneLenght = 2,
                  preProcess = "zv")

predSVM0Long <- predict(SVM0Long, VBuild0Long)

postResample(predSVM0Long, VBuild0Long$LONGITUDE) -> SVM0LongMetrics
SVM0LongMetrics

# Building 0 Latitude
SVM0Lat <- train(LATITUDE ~ ., 
                 SampleBuild0Lat,
                 method = "svmLinear",
                 trControl = trainControl(method = "repeatedcv", 
                                          number = 5, 
                                          repeats = 2),
                 tuneLenght = 2,
                 preProcess = "zv")

predSVM0Lat <- predict(SVM0Lat, VBuild0Lat)

postResample(predSVM0Lat, VBuild0Lat$LATITUDE) -> SVM0LatMetrics
SVM0LatMetrics

# Building 0 Floor
SVM0Floor <- train(FLOOR ~ ., 
                   SampleBuild0Floor,
                   method = "svmLinear",
                   trControl = trainControl(method = "repeatedcv", 
                                            number = 5, 
                                            repeats = 2),
                   tuneLenght = 2,
                   preProcess = "zv")

predSVM0Floor <- predict(SVM0Floor, VBuild0Floor)

postResample(predSVM0Floor, VBuild0Floor$FLOOR) -> SVM0FloorMetrics
SVM0FloorMetrics

# Building 1 Longitude
SVM1Long <- train(LONGITUDE ~ ., 
                  SampleBuild1Long,
                  method = "svmLinear",
                  trControl = trainControl(method = "repeatedcv", 
                                           number = 5, 
                                           repeats = 2),
                  tuneLenght = 2,
                  preProcess = "zv")

predSVM1Long <- predict(SVM1Long, VBuild1Long)

postResample(predSVM1Long, VBuild1Long$LONGITUDE) -> SVM1LongMetrics
SVM1LongMetrics

# Building 1 Latitude
SVM1Lat <- train(LATITUDE ~ ., 
                 SampleBuild1Lat,
                 method = "svmLinear",
                 trControl = trainControl(method = "repeatedcv", 
                                          number = 5, 
                                          repeats = 2),
                 tuneLenght = 2,
                 preProcess = "zv")

predSVM1Lat <- predict(SVM1Lat, VBuild1Lat)

postResample(predSVM1Lat, VBuild1Lat$LATITUDE) -> SVM1LatMetrics
SVM1LatMetrics

# Building 1 Floor
SVM1Floor <- train(FLOOR ~ ., 
                   SampleBuild0Floor,
                   method = "svmLinear",
                   trControl = trainControl(method = "repeatedcv", 
                                            number = 5, 
                                            repeats = 2),
                   tuneLenght = 2,
                   preProcess = "zv")

predSVM1Floor <- predict(SVM1Floor, VBuild1Floor)

postResample(predSVM1Floor, VBuild1Floor$FLOOR) -> SVM1FloorMetrics
SVM1FloorMetrics

# Building 2 Longitude
SVM2Long <- train(LONGITUDE ~ ., 
                  SampleBuild2Long,
                  method = "svmLinear",
                  trControl = trainControl(method = "repeatedcv", 
                                           number = 5, 
                                           repeats = 2),
                  tuneLenght = 2,
                  preProcess = "zv")

predSVM2Long <- predict(SVM2Long, VBuild2Long)

postResample(predSVM2Long, VBuild2Long$LONGITUDE) -> SVM2LongMetrics
SVM2LongMetrics

# Building 2 Latitude
SVM2Lat <- train(LATITUDE ~ ., 
                 SampleBuild2Lat,
                 method = "svmLinear",
                 trControl = trainControl(method = "repeatedcv", 
                                          number = 5, 
                                          repeats = 2),
                 tuneLenght = 2,
                 preProcess = "zv")

predSVM2Lat <- predict(SVM2Lat, VBuild2Lat)

postResample(predSVM2Lat, VBuild2Lat$LATITUDE) -> SVM2LatMetrics
SVM2LatMetrics

# Building 2 Floor
SVM2Floor <- train(FLOOR ~ ., 
                   SampleBuild2Floor,
                   method = "svmLinear",
                   trControl = trainControl(method = "repeatedcv", 
                                            number = 5, 
                                            repeats = 2),
                   tuneLenght = 2,
                   preProcess = "zv")

predSVM2Floor <- predict(SVM2Floor, VBuild2Floor)

postResample(predSVM2Floor, VBuild2Floor$FLOOR) -> SVM2FloorMetrics
SVM2FloorMetrics

### ---- RF Modelization ----
set.seed(1003)
# Building 0 Longitude
RFGrid <- expand.grid(mtry=c(1:5))
RF0Long <- train(LONGITUDE ~ ., 
                 SampleBuild0Long,
                 method = "rf",
                 trControl = trainControl(method = "repeatedcv",
                                          number = 5,
                                          repeats = 2),
                 tuneGrid = RFGrid,
                 tuneLenght = 2,
                 preProcess = "zv")

predRF0Long <- predict(RF0Long, VBuild0Long)

postResample(predRF0Long, VBuild0Long$LONGITUDE) -> RF0LongMetrics
RF0LongMetrics

# Building 0 Latitude
RF0Lat <- train(LATITUDE ~ ., 
                 SampleBuild0Lat,
                 method = "rf",
                 trControl = trainControl(method = "repeatedcv",
                                          number = 5,
                                          repeats = 2),
                 tuneGrid = RFGrid,
                 tuneLenght = 2,
                 preProcess = "zv")

predRF0Lat <- predict(RF0Lat, VBuild0Lat)

postResample(predRF0Lat, VBuild0Lat$LATITUDE) -> RF0LatMetrics
RF0LatMetrics

# Building 0 Floor
RF0Floor <- train(FLOOR ~ ., 
                  SampleBuild0Floor,
                  method = "rf",
                  trControl = trainControl(method = "repeatedcv",
                                          number = 5,
                                          repeats = 2),
                  tuneGrid = RFGrid,
                  tuneLenght = 2,
                  preProcess = "zv")

predRF0Floor <- predict(RF0Floor, VBuild0Floor)

postResample(predRF0Floor, VBuild0Floor$FLOOR) -> RF0FloorMetrics
RF0FloorMetrics

# Building 1 Longitude
RFGrid <- expand.grid(mtry=c(1:5))
RF1Long <- train(LONGITUDE ~ ., 
                 SampleBuild1Long,
                 method = "rf",
                 trControl = trainControl(method = "repeatedcv",
                                          number = 5,
                                          repeats = 2),
                 tuneGrid = RFGrid,
                 tuneLenght = 2,
                 preProcess = "zv")

predRF1Long <- predict(RF1Long, VBuild1Long)

postResample(predRF1Long, VBuild1Long$LONGITUDE) -> RF1LongMetrics
RF1LongMetrics

# Building 1 Latitude
RF1Lat <- train(LATITUDE ~ ., 
                SampleBuild1Lat,
                method = "rf",
                trControl = trainControl(method = "repeatedcv",
                                         number = 5,
                                         repeats = 2),
                tuneGrid = RFGrid,
                tuneLenght = 2,
                preProcess = "zv")

predRF1Lat <- predict(RF1Lat, VBuild1Lat)

postResample(predRF1Lat, VBuild1Lat$LATITUDE) -> RF1LatMetrics
RF1LatMetrics

# Building 1 Floor
RF1Floor <- train(FLOOR ~ ., 
                  SampleBuild1Floor,
                  method = "rf",
                  trControl = trainControl(method = "repeatedcv",
                                           number = 5,
                                           repeats = 2),
                  tuneGrid = RFGrid,
                  tuneLenght = 2,
                  preProcess = "zv")

predRF1Floor <- predict(RF1Floor, VBuild1Floor)

postResample(predRF1Floor, VBuild1Floor$FLOOR) -> RF1FloorMetrics
RF1FloorMetrics

# Building 2 Longitude
RFGrid <- expand.grid(mtry=c(1:5))
RF2Long <- train(LONGITUDE ~ ., 
                 SampleBuild2Long,
                 method = "rf",
                 trControl = trainControl(method = "repeatedcv",
                                          number = 5,
                                          repeats = 2),
                 tuneGrid = RFGrid,
                 tuneLenght = 2,
                 preProcess = "zv")

predRF2Long <- predict(RF2Long, VBuild2Long)

postResample(predRF2Long, VBuild2Long$LONGITUDE) -> RF2LongMetrics
RF2LongMetrics

# Building 2 Latitude
RF2Lat <- train(LATITUDE ~ ., 
                SampleBuild2Lat,
                method = "rf",
                trControl = trainControl(method = "repeatedcv",
                                         number = 5,
                                         repeats = 2),
                tuneGrid = RFGrid,
                tuneLenght = 2,
                preProcess = "zv")

predRF2Lat <- predict(RF2Lat, VBuild2Lat)

postResample(predRF2Lat, VBuild2Lat$LATITUDE) -> RF2LatMetrics
RF2LatMetrics

# Building 2 Floor
RF2Floor <- train(FLOOR ~ ., 
                  SampleBuild2Floor,
                  method = "rf",
                  trControl = trainControl(method = "repeatedcv",
                                           number = 5,
                                           repeats = 2),
                  tuneGrid = RFGrid,
                  tuneLenght = 2,
                  preProcess = "zv")

predRF2Floor <- predict(RF2Floor, VBuild2Floor)

postResample(predRF2Floor, VBuild2Floor$FLOOR) -> RF2FloorMetrics
RF2FloorMetrics

### ---- Model Comparison ----
## Creating data frames for performance and accuracy metrics
PerformanceMetrics <- data.frame(kNN0LongMetrics, 
                                 kNN0LatMetrics,
                                 kNN1LongMetrics,
                                 kNN1LatMetrics,
                                 kNN2LongMetrics,
                                 kNN2LatMetrics,
                                 SVM0LongMetrics,
                                 SVM0LatMetrics,
                                 SVM1LongMetrics,
                                 SVM1LatMetrics,
                                 SVM2LongMetrics,
                                 SVM2LatMetrics,
                                 RF0LongMetrics,
                                 RF0LatMetrics,
                                 RF1LongMetrics,
                                 RF1LatMetrics,
                                 RF2LongMetrics,
                                 RF2LatMetrics)

AccuracyMetrics <- data.frame(kNN0FloorMetrics,
                              kNN1FloorMetrics,
                              kNN2FloorMetrics,
                              SVM0FloorMetrics,
                              SVM1FloorMetrics,
                              SVM2FloorMetrics,
                              RF0FloorMetrics,
                              RF1FloorMetrics,
                              RF2FloorMetrics)

## Transposing the data frame
PerformanceMetrics <- data.frame(t(PerformanceMetrics))

AccuracyMetrics <- data.frame(t(AccuracyMetrics))

## Naming the rows
PerformanceMetrics$Algorithms <- rownames(PerformanceMetrics)

AccuracyMetrics$Algorithms <- rownames(AccuracyMetrics)

## Reordering the columns
PerformanceMetrics <- PerformanceMetrics[, c(4,1,2,3)]

AccuracyMetrics <- AccuracyMetrics[, c(3,1,2)]

## Arranging by Rsquared, MAE and Accuracy to see the best models
PerformanceMetrics %>% 
  arrange(desc(Rsquared)) 

PerformanceMetrics %>% 
  arrange(MAE) 

AccuracyMetrics %>% 
  arrange(desc(Accuracy))

### ---- Error Check ----
## Creating data frames for random forest predictions
Building0pred <- data.frame(building = "0",
                            pred.longitude = predkNN0Long, 
                            pred.latitude = predkNN0Lat, 
                            pred.floor = predRF0Floor,
                            valid.longitude = VBuild0Long$LONGITUDE,
                            valid.latitude = VBuild0Lat$LATITUDE,
                            valid.floor = VBuild0Floor$FLOOR)

Building1pred <- data.frame(building = "1",
                            pred.longitude = predRF1Long, 
                            pred.latitude = predkNN1Lat, 
                            pred.floor = predRF1Floor,
                            valid.longitude = VBuild1Long$LONGITUDE,
                            valid.latitude = VBuild1Lat$LATITUDE,
                            valid.floor = VBuild1Floor$FLOOR)

Building2pred <- data.frame(building = "2",
                            pred.longitude = predRF2Long, 
                            pred.latitude = predkNN2Lat, 
                            pred.floor = predSVM2Floor,
                            valid.longitude = VBuild2Long$LONGITUDE,
                            valid.latitude = VBuild2Lat$LATITUDE,
                            valid.floor = VBuild2Floor$FLOOR)

## Combining the data frames
ErrorData <- rbind(Building0pred, Building1pred, Building2pred)

## Calculating Errors
ErrorData$err.long <- abs(ErrorData$valid.longitude - ErrorData$pred.longitude)

ErrorData$err.lat <- abs(ErrorData$valid.latitude - ErrorData$pred.latitude)

ErrorData %>% 
  mutate_at(c("valid.floor", "pred.floor"), as.numeric) -> ErrorData

ErrorData$err.floor <- abs(ErrorData$valid.floor - ErrorData$pred.floor)
ErrorData$err.floor <- as.factor(ErrorData$err.floor)

ErrorData %>% 
  mutate_at(c("valid.floor",
              "pred.floor"),
            as.numeric) %>% 
  mutate(diff.floor = ifelse(valid.floor == pred.floor, 0, 1 )) %>% 
  mutate_at(c("valid.floor",
              "pred.floor"),
            as.factor) -> ErrorData

str(ErrorData)

## Checking Errors

confusionMatrix(ErrorData$pred.floor, ErrorData$valid.floor)

ErrorData %>% 
  filter(building == 0) %>% 
  group_by(diff.floor) %>% 
  count(valid.floor)

ErrorData %>% 
  filter(building == 0) %>% 
  group_by(err.floor) %>% 
  plot_ly(x = ~pred.longitude, 
          y = ~pred.latitude, 
          z = ~pred.floor, 
          colors = c("red","blue")) %>%
  add_markers(color = ~err.floor == 0, size = 1) %>%
  layout(title = "Building 0 Floor Error Check",
         scene = list(xaxis = list(title = "Longitude"),
                      yaxis = list(title = "Latitude"),
                      zaxis = list(title = "Floor")))

ErrorData %>%  
  filter(building == 1) %>% 
  group_by(diff.floor) %>% 
  count(valid.floor)

ErrorData %>% 
  filter(building == 1) %>% 
  group_by(err.floor) %>% 
  plot_ly(x = ~pred.longitude, 
          y = ~pred.latitude, 
          z = ~pred.floor, 
          colors = c("red","blue")) %>%
  add_markers(color = ~err.floor == 0, size = 1) %>%
  layout(title = "Building 1 Floor Error Check",
         scene = list(xaxis = list(title = "Longitude"),
                      yaxis = list(title = "Latitude"),
                      zaxis = list(title = "Floor")))

ErrorData %>% 
  filter(building == 2) %>% 
  group_by(diff.floor) %>% 
  count(valid.floor)

ErrorData %>% 
  filter(building == 2) %>% 
  group_by(err.floor) %>% 
  plot_ly(x = ~pred.longitude, 
          y = ~pred.latitude, 
          z = ~pred.floor, 
          colors = c("red","blue")) %>%
  add_markers(color = ~err.floor == 0, size = 1) %>%
  layout(title = "Building 2 Floor Error Check",
         scene = list(xaxis = list(title = "Longitude"),
                      yaxis = list(title = "Latitude"),
                      zaxis = list(title = "Floor")))

## Error Visualization
## Longitude & Latitude
ErrorData %>% 
  ggplot(aes(x = valid.longitude, y = valid.latitude)) +
  geom_point(aes(x = valid.longitude, 
                 y = valid.latitude), 
             color = "red") +
  geom_point(aes(x = pred.longitude, 
                 y = pred.latitude), 
             color = "blue") +
  geom_label(aes(x = -7400, y = 4864960, label = "Actual"), 
             color = "red", 
             size = 4) +
  geom_label(aes(x = -7400, y = 4864930, label = "Pred"), 
             color = "blue", 
             size = 4) +
  labs(title = "Actual Data on Validation vs Predictions") + 
  ylab("Latitude") + 
  xlab("Longitude") + 
  theme_light()
