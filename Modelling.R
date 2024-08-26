library(dplyr)
library(caret)
library(randomForest)
library(xgboost)
library(MLmetrics)
library(doParallel)
library(ggplot2)

# Assign Cores
cl <- makeCluster(4)
registerDoParallel(cl)

# Load and preprcossing the data
data <- read.csv("diabetes_012_health_indicators_BRFSS2015.csv")
data <- data %>%
  mutate(across(!c(BMI, MentHlth, PhysHlth), factor))
levels(data$Diabetes_012) <- c("Normal", "Prediabetes", "Diabetes")

# Data Partition
set.seed(8-22-2024)
train_index <- createDataPartition(data$Diabetes_012, p = 0.2, list = FALSE)

train_data <- data[train_index, ]

## Create test set from the remaining 80%
remaining_data <- data[-train_index, ]

## Randomly sample 100 instances from the remaining data for test set
test_index <- sample(1:nrow(remaining_data), 100)
test_data <- remaining_data[test_index, ]

# Set up Cross Validation
ctrl <- trainControl(method = "cv", number = 5, classProbs = TRUE, 
                     summaryFunction = multiClassSummary, verboseIter=FALSE,
                     allowParallel=FALSE)

# Random Forest Modelling
set.seed(8-22-2024)
rf_model_cv <- train(
  Diabetes_012 ~ .,
  data = train_data,
  method = "rf",
  trControl = ctrl,
  importance = TRUE,
  ntree = 500,
  do.trace = 100
)

# Print the results of Random Forest model
print(rf_model_cv)
varImp(rf_model_cv)

# XGBoost Modelling
set.seed(8-22-2024)
xgb_model_cv <- train(
  Diabetes_012 ~ .,
  data = train_data,
  method = "xgbTree",
  trControl = ctrl
)

# Print the Restuls of XGBoost
print(xgb_model_cv)
varImp(xgb_model_cv)


# Variable Selection
importance_xgb <- varImp(xgb_model_cv)
importance_xgb <- importance_xgb$importance
importance_xgb$Feature <- rownames(importance_xgb)
importance_xgb <- importance_xgb[order(-importance_xgb$Overall),]

## Method 1: Select top N variables
N <- 15
top_n_vars <- importance_xgb$Feature[1:N]

## Method 2: Cumulative importance threshold -> new_model1
cumulative_importance <- cumsum(importance_xgb$Overall) / sum(importance_xgb$Overall)
threshold <- 0.90
selected_vars_cumulative <- importance_xgb$Feature[cumulative_importance <= threshold]

selected_vars_original <- unique(sapply(selected_vars_cumulative, function(x) sub("\\d+$", "", x)))

## Method 3: Mean importance threshold -> new_model2
mean_importance <- mean(importance_xgb$Overall)
selected_vars_mean <- importance_xgb$Feature[importance_xgb$Overall >= 1.5 * mean_importance]

selected_vars_2_original <- unique(sapply(selected_vars_mean, function(x) sub("\\d+$", "", x)))

## Method 4: Maximum importance ratio
max_importance <- max(importance_xgb$Overall)
selected_vars_max <- importance_xgb$Feature[importance_xgb$Overall >= 0.05 * max_importance]

## Visulization of Variable importance
ggplot(importance_xgb, aes(x = reorder(Feature, Overall), y = Overall)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  theme_minimal() +
  labs(title = "Variable Importance", x = "Features", y = "Importance")

# Train new model1 with selected variables
new_train_data <- train_data[,c(selected_vars_original, "Diabetes_012")]

set.seed(8-24-2024)
new_xgb_model_cv <- train(
  Diabetes_012 ~ .,
  data = new_train_data,
  method = "xgbTree",
  trControl = ctrl
)

print(new_xgb_model_cv)
varImp(new_xgb_model_cv)

# Train new model2 with selected variables
new2_train_data <- train_data[,c(selected_vars_2_original, "Diabetes_012")]

set.seed(8-24-2024)
new2_xgb_model_cv <- train(
  Diabetes_012 ~ .,
  data = new2_train_data,
  method = "xgbTree",
  trControl = ctrl
)

print(new2_xgb_model_cv)
varImp(new2_xgb_model_cv)

# Performance comparison
performance_comparison <- data.frame(
  Model = c("Original", "New", "New2"),
  Accuracy = c(max(xgb_model_cv$results$Accuracy),
               max(new_xgb_model_cv$results$Accuracy),
               max(new2_xgb_model_cv$results$Accuracy))
)

print(performance_comparison)


# Prediction on Test set
pred_test <- predict(new2_xgb_model_cv, test_data)
accuracy <- mean(pred_test == test_data$Diabetes_012)
# conf_matrix <- confusionMatrix(factor(pred_test), factor(test_data$Diabetes_012))
accuracy