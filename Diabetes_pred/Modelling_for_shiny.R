library(dplyr)
library(caret)
library(xgboost)
library(doParallel)

# Assign Cores
cl <- makeCluster(4)
registerDoParallel(cl)

# Load and preprcossing the data
data <- read.csv("diabetes_012_health_indicators_BRFSS2015.csv")
data <- data %>%
  select(c("HighBP", "BMI", "DiffWalk", "HighChol", "GenHlth", "Diabetes_012")) %>%
  mutate(across(!c(BMI), factor))
levels(data$Diabetes_012) <- c("Normal", "Prediabetes", "Diabetes")

# Stratified sampling (20% of data)
set.seed(8-26-2024)
sample_indices <- createDataPartition(data$Diabetes_012, p = 0.2, list = FALSE)
sampled_data <- data[sample_indices, ]

# XGBoost Modelling
set.seed(8-26-2024)
final_xgb_model <- train(
  Diabetes_012 ~ .,
  data = sampled_data,
  method = "xgbTree",
  nthread = 4,
  verbose=TRUE,
  print_every_n = 10)

# Print the Restuls of XGBoost
print(final_xgb_model)

# Save the model for Shiny app
saveRDS(final_xgb_model, "final_diabetes_xgb_model.rds")