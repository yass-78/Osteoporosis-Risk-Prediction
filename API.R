# Load necessary libraries
library(plumber)  # For creating REST APIs in R
library(caret)  # For building predictive models
library(dplyr)   # For data manipulation

# Load the pre-trained logistic regression model
load("C:/Users/julia/OneDrive/Documentos/Treball bioinfo/logistic_model.RData")  # Asegúrate de que logistic_model.RData esté en el mismo directorio

# Define expected levels for each factor (categorical variable)
levels_gender <- c("Male", "Female")
levels_family_history <- c("Yes", "No")
levels_hormonal_changes <- c("Normal", "Postmenopausal")
levels_race_ethnicity <- c("Caucasian", "Asian", "African American")
levels_body_weight <- c("Normal", "Underweight")
levels_calcium_intake <- c("Low", "Adequate")
levels_vitamin_d_intake <- c("Sufficient", "Insufficient")
levels_physical_activity <- c("Sedentary", "Active")
levels_smoking <- c("Yes", "No")
levels_alcohol_consumption <- c("Moderate", "None")
levels_medications <- c("Corticosteroids", "None")
levels_prior_fractures <- c("Yes", "No")


# Endpoint for prediction
#* @apiTitle Osteoporosis Prediction API
#* @apiDescription This API predicts the likelihood of osteoporosis based on clinical and lifestyle factors. 
#*                 It uses a logistic regression model trained on relevant patient data.
#*                 <br><br>
#*                 <br><b>INPUTS:</b><br>
#*                 <br> - <b>Age:</b> Age of the patient in years (e.g., 78).
#*                 <br> - <b>Gender:</b> Gender of the patient. Possible values: "Male", "Female".
#*                 <br> - <b>HormonalChanges:</b> Hormonal changes of the patient. Possible values: "Normal", "Postmenopausal".
#*                 <br> - <b>FamilyHistory:</b> Family history of osteoporosis. Possible values: "Yes", "No".
#*                 <br> - <b>RaceEthnicity:</b> Race or ethnicity of the patient. Possible values: "Caucasian", "Asian", "African American".
#*                 <br> - <b>BodyWeight:</b> Body weight category. Possible values: "Normal", "Underweight".
#*                 <br> - <b>CalciumIntake:</b> Calcium intake level. Possible values: "Low", "Adequate".
#*                 <br> - <b>VitaminDIntake:</b> Vitamin D intake level. Possible values: "Sufficient", "Insufficient".
#*                 <br> - <b>PhysicalActivity:</b> Physical activity level. Possible values: "Sedentary", "Active".
#*                 <br> - <b>Smoking:</b> Smoking status. Possible values: "Yes", "No".
#*                 <br> - <b>AlcoholConsumption:</b> Alcohol consumption level. Possible values: "Moderate", "None".
#*                 <br> - <b>Medications:</b> Medication type. Possible values: "Corticosteroids", "None".
#*                 <br> - <b>PriorFractures:</b> History of prior fractures. Possible values: "Yes", "No".
                
#* @param Gender  Gender of the patient. Possible values: "Male", "Female".
#* @param Age  Age of the patient in years (e.g., 78).
#* @param HormonalChanges  Hormonal changes of the patient. Possible values: "Normal", "Postmenopausal".
#* @param FamilyHistory  Family history of osteoporosis. Possible values: "Yes", "No".
#* @param RaceEthnicity  Race or ethnicity of the patient. Possible values: "Caucasian", "Asian", "African American".
#* @param BodyWeight  Body weight category. Possible values: "Normal", "Underweight".
#* @param CalciumIntake  Calcium intake level. Possible values: "Low", "Adequate".
#* @param VitaminDIntake  Vitamin D intake level. Possible values: "Sufficient", "Insufficient".
#* @param PhysicalActivity  Physical activity level. Possible values: "Sedentary", "Active".
#* @param Smoking  Smoking status. Possible values: "Yes", "No".
#* @param AlcoholConsumption  Alcohol consumption level. Possible values: "Moderate", "None".
#* @param Medications  Medication type. Possible values: "Corticosteroids", "None".
#* @param PriorFractures  History of prior fractures. Possible values: "Yes", "No".

#* @post /predict_logistic
predict_logistic <- function(Gender, Age, HormonalChanges, FamilyHistory, RaceEthnicity, BodyWeight,
                             CalciumIntake, VitaminDIntake, PhysicalActivity,
                             Smoking, AlcoholConsumption, Medications, PriorFractures) {
  
  # Create a data frame with the input data
  input_data <- data.frame(
    Gender = as.factor(Gender),
    Age = as.numeric(Age),
    Hormonal.Changes = as.factor(HormonalChanges),
    Family.History = as.factor(FamilyHistory),
    Race.Ethnicity = as.factor(RaceEthnicity),
    Body.Weight = as.factor(BodyWeight),
    Calcium.Intake = as.factor(CalciumIntake),
    Vitamin.D.Intake = as.factor(VitaminDIntake),
    Physical.Activity = as.factor(PhysicalActivity),
    Smoking = as.factor(Smoking),
    Alcohol.Consumption = as.factor(AlcoholConsumption),
    Medications = as.factor(Medications),
    Prior.Fractures = as.factor(PriorFractures)
  )
  
  # Adjust the levels of the factors to match expected values
  levels(input_data$Gender) <- levels_gender
  levels(input_data$Family.History) <- levels_family_history
  levels(input_data$Race.Ethnicity) <- levels_race_ethnicity
  levels(input_data$Body.Weight) <- levels_body_weight
  levels(input_data$Calcium.Intake) <- levels_calcium_intake
  levels(input_data$Vitamin.D.Intake) <- levels_vitamin_d_intake
  levels(input_data$Physical.Activity) <- levels_physical_activity
  levels(input_data$Smoking) <- levels_smoking
  levels(input_data$Alcohol.Consumption) <- levels_alcohol_consumption
  levels(input_data$Medications) <- levels_medications
  levels(input_data$Prior.Fractures) <- levels_prior_fractures
  
  # Make predictions using the pre-trained model
  probs <- predict(model, newdata = input_data, type = "prob") # Probability prediction
  prediction <- predict(model, newdata = input_data) # Class prediction
  
  # Return the prediction results
  list(
    probability = probs$Yes, # Probability of having osteoporosis
    prediction = as.character(prediction) # Predicted class ("Yes" or "No")
  )
}

