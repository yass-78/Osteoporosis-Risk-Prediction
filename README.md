
# Osteoporosis Prediction Project

This project aims to develop a prediction system for osteoporosis using Logistic Regression and Random Forest models. The system predicts osteoporosis risk based on a variety of clinical and lifestyle factors. Below is a detailed explanation of the key components and scripts in this project.

## Documents Overview

**Treball_Final_Bioinfo.R**
This script contains the entire process of training and evaluating a Logistic Regression model for osteoporosis prediction. The key steps include:

1. Package Installation
   
2. Dataset Preparation:
   - Loads the `osteoporosis.csv` dataset, removes irrelevant columns, handles missing data, and converts categorical variables into factors.
   
3. Model Training:
   - Trains a Logistic Regression model using 70% of the dataset (training set) and evaluates it using confusion matrix, ROC curve, and Precision-Recall curve.

4. Feature Importance Evaluation:
   - A Random Forest model is trained to identify the most influential features for predicting osteoporosis.

5. Model Saving:
   - Saves the trained Logistic Regression and Random Forest models for future use.

**API.R**
This script sets up a **REST API** using the plumber package to provide osteoporosis predictions based on the trained Logistic Regression model. The key steps are:

1. Library Loading

2. API Endpoint Definition:
   - Defines the predict_logistic endpoint that accepts user inputs such as gender, age, family history, physical activity, etc., and returns the probability and prediction (Yes/No) of osteoporosis.

3. Input Format:
   - Accepts both categorical (e.g., gender, family history) and numeric (e.g., age) input variables for making predictions.

4. Prediction:
   - Uses the trained Logistic Regression model to make predictions based on the provided inputs.

**Run_API.R**
This script runs the API defined in 'API.R' on a local server. 

**Shiny App (app.R)**
   - The Shiny app provides an interactive user interface for predicting osteoporosis risk in real time. It allows users to input clinical and lifestyle variables and see immediate results.

Key Features:
1. Live Predictions: 
   - Results update as you change input values.

2. Color-Coded Output:
   - Red: "Yes" (High risk of osteoporosis)
   - Green: "No" (Low risk of osteoporosis)

3. Age Selection: 
   - Uses a slider for easy age selection.

4. Batch Predictions (CSV Upload):
   - Users can upload a CSV file containing data for multiple individuals. The app processes the data, predicts osteoporosis risk for each record, and allows users to download the results as a new CSV file.

**How to Use the Batch Prediction Feature:**
1. Navigate to the Batch Prediction tab in the Shiny app.
2. Upload a properly formatted CSV file (columns must match the API input requirements, e.g., Gender, Age, etc.).
3. Click the "Process CSV" button.
4. View the predictions in the table displayed on the app.
5. Download the results using the "Download Results as CSV" button.


**How to Run:**
1. Ensure the API is running on port 8000 by executing Run_API.R.

2. Run the Shiny app script (app.R) in RStudio:

3. Open the app in your browser, input values, and observe live predictions.

---

## How to run the Shiny App

Run docker-compose.yml using: docker-compose up. This will run the plumber API from port http://0.0.0.0:8000 and APP from http://0.0.0.0:8180.

Make sure you have docker, docker-compose plug-in and are running on linux! (We used colima for this)

---

## Required Packages

The following R packages are required to run the project:

- `plumber`: For creating REST APIs in R.
- `shiny`: For building interactive web applications.
- `httr`: For sending HTTP requests to the API.
- `jsonlite`: For parsing JSON data.
- `caret`: For building predictive models.
- `dplyr`: For data manipulation.
- `PRROC`: For Precision-Recall curve creation.
- `pROC`: For ROC curve creation and evaluation.
- `smotefamily`: For handling imbalanced data through SMOTE.
- `randomForest`: For building Random Forest models.
- `shinycssloaders`: Adds a spinner when the app is loading or processing data..
- `shinyjs`: Provides JavaScript capabilities to disable/enable buttons and improve interactivity.
- `DT`: For rendering interactive tables in the Shiny app.  
