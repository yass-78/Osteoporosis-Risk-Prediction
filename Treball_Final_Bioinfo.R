#Install required packages for data handling, model training, and evaluation
# install.packages("PRROC") 
# install.packages("pROC")
# install.packages("smotefamily")
# install.packages("randomForest")

# Load the necessary libraries
library(caret)    # For model training and validation
library(dplyr)     # For data manipulation
library(smotefamily) # For oversampling techniques
library(ggplot2) # For data visualization
library(pROC)    # For ROC curve analysis
library(randomForest)# For Random Forest algorithm
library(PRROC)    # For Precision-Recall Curves

# Load the dataset ensuring that is saved at the specified path
data <- read.csv("api/data/osteoporosis.csv")

# Remove irrelevant columns that do not contribute to prediction such as "Id
data <- data %>% select(-Id, -Medical.Conditions)

# Preview the first few rows of the dataset
head(data)

# Check for missing values in the dataset
sum(is.na(data)) # Returns the number of missing values

# Check column names
colnames(data)

# Convert categorical variables to factors
data$Gender <- as.factor(data$Gender)
data$Hormonal.Changes <- as.factor(data$Hormonal.Changes)
data$Family.History <- as.factor(data$Family.History)
data$Race.Ethnicity <- as.factor(data$Race.Ethnicity)
data$Body.Weight <- as.factor(data$Body.Weight)
data$Calcium.Intake <- as.factor(data$Calcium.Intake)
data$Vitamin.D.Intake <- as.factor(data$Vitamin.D.Intake)
data$Physical.Activity <- as.factor(data$Physical.Activity)
data$Smoking <- as.factor(data$Smoking)
data$Alcohol.Consumption <- as.factor(data$Alcohol.Consumption)
data$Medications <- as.factor(data$Medications)
data$Prior.Fractures <- as.factor(data$Prior.Fractures)

# Convert the target variable (Osteoporosis) into a factor
# Replace numerical values (1, 0) with "Yes" and "No"
data$Osteoporosis <- ifelse(data$Osteoporosis == 1, "Yes", "No")
data$Osteoporosis <- as.factor(data$Osteoporosis) 

# Split the dataset into training (70%) and validation (30%) sets
set.seed(123) # Set seed for reproducibility
trainIndex <- createDataPartition(data$Osteoporosis, p = 0.7, list = FALSE) 
trainData <- data[trainIndex, ] # Training dataset
valData <- data[-trainIndex, ] # Validation dataset

# Check the distribution of the target variable in both datasets
table(trainData$Osteoporosis) # Count of each class in training data
table(valData$Osteoporosis) # Count of each class in validation data

# Ensure that the levels of the target variable are consistent across both datasets
levels(valData$Osteoporosis) <- levels(trainData$Osteoporosis)

# Train a logistic regression model on the training dataset
model <- train(Osteoporosis ~ ., data = trainData, method = "glm", family = "binomial")

# Summarize the trained model
summary(model)

# Predict probabilities and classes for the validation dataset
probs <- predict(model, newdata = valData, type = "prob") # Generates probabilities
predictions <- predict(model, newdata = valData) # Class predictions

# Evaluate the model's performance using a confusion matrix
cm <- confusionMatrix(predictions, valData$Osteoporosis)
print("Confusion Matrix:") 
print(cm) # Outputs the confusion matrix

# Convert the confusion matrix into a data frame for visualization
cm_df <- as.data.frame(as.table(cm))
colnames(cm_df) <- c("Predicted", "Actual", "Freq") 

# Plot the confusion matrix
ggplot(cm_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), color = "black", size = 4) +
  scale_fill_gradient(low = "lightblue", high = "blue") +
  labs(title = "Confusion Matrix", x = "Actual Class", y = "Predicted Class") +
  theme_minimal()

# Generate and plot the ROC curve
roc_curve <- roc(valData$Osteoporosis, probs$Yes) # Generate ROC curve data
ggplot(data.frame(x = roc_curve$specificities, y = roc_curve$sensitivities), aes(x, y)) +
  geom_line(color = "blue") +
  labs(title = "ROC Curve", x = "1 - Specificity", y = "Sensitivity") +
  theme_minimal()

# Argumentation of the ROC curve results:
# - A perfect model would have the curve reaching the top left corner (0, 1).
# - The steeper the curve, the better the model distinguishes between classes.
# - AUC is a summary measure of the ROC curve:
#   - AUC = 0.5: Random guessing.
#   - AUC = 1: Perfect classification.

# Generate the Precision-Recall Curve
pr_curve <- pr.curve(scores.class0 = probs$Yes, weights.class0 = as.numeric(valData$Osteoporosis) - 1, curve = TRUE)

# Convert PR curve data to a data frame
df <- data.frame(
  recall = pr_curve$curve[,1], 
  precision = pr_curve$curve[,2]
)

# Plot the Precision-Recall Curve
ggplot(df, aes(x = recall, y = precision)) +
  geom_line(color = "red", size = 1) +
  labs(title = "Precision-Recall Curve", x = "Recall", y = "Precision") +
  theme_minimal()

# Feature Importance: Identify the most influential variables
# Train a Random Forest model to extract feature importance
modelRF <- randomForest(Osteoporosis ~ ., data = trainData) 

# Extract and visualize feature importance
importance_values <- importance(modelRF) 
importance_df <- data.frame(Feature = rownames(importance_values), Importance = importance_values[, 1])

# Plot feature importance using ggplot2
ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + # Flips the x and y axes for better readability
  labs(title = "Feature Importance", x = "Feature", y = "Importance") +
  theme_minimal()

# Save the trained models for future use
save(model, file = paste0("api/data/logistic_model.RData"))
save(modelRF, file = paste0("api/data/random_forest_model.RData"))

# List files in the directory to confirm saved models
list.files()

