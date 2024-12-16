# Load required libraries
library(shiny)
library(httr)
library(jsonlite)

# Define the UI
ui <- fluidPage(
  titlePanel("Osteoporosis Prediction App"),
  
  sidebarLayout(
    sidebarPanel(
      # Input fields for each parameter
      numericInput("Age", "Age (years):", value = 50, min = 1),
      selectInput("Gender", "Gender:", choices = c("Male", "Female")),
      selectInput("HormonalChanges", "Hormonal Changes:", choices = c("Normal", "Postmenopausal")),
      selectInput("FamilyHistory", "Family History of Osteoporosis:", choices = c("Yes", "No")),
      selectInput("RaceEthnicity", "Race/Ethnicity:", choices = c("Caucasian", "Asian", "African American")),
      selectInput("BodyWeight", "Body Weight:", choices = c("Normal", "Underweight")),
      selectInput("CalciumIntake", "Calcium Intake Level:", choices = c("Low", "Adequate")),
      selectInput("VitaminDIntake", "Vitamin D Intake Level:", choices = c("Sufficient", "Insufficient")),
      selectInput("PhysicalActivity", "Physical Activity Level:", choices = c("Sedentary", "Active")),
      selectInput("Smoking", "Smoking Status:", choices = c("Yes", "No")),
      selectInput("AlcoholConsumption", "Alcohol Consumption Level:", choices = c("Moderate", "None")),
      selectInput("Medications", "Medications:", choices = c("Corticosteroids", "None")),
      selectInput("PriorFractures", "History of Prior Fractures:", choices = c("Yes", "No")),
      
      # Button to trigger the prediction
      actionButton("predict_btn", "Predict")
    ),
    
    mainPanel(
      # Output fields for prediction results
      h3("Prediction Results"),
      verbatimTextOutput("prediction"),
      verbatimTextOutput("probability")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # API call when the button is clicked
  observeEvent(input$predict_btn, {
    # Collect inputs into a list
    inputs <- list(
      Gender = input$Gender,
      Age = input$Age,
      HormonalChanges = input$HormonalChanges,
      FamilyHistory = input$FamilyHistory,
      RaceEthnicity = input$RaceEthnicity,
      BodyWeight = input$BodyWeight,
      CalciumIntake = input$CalciumIntake,
      VitaminDIntake = input$VitaminDIntake,
      PhysicalActivity = input$PhysicalActivity,
      Smoking = input$Smoking,
      AlcoholConsumption = input$AlcoholConsumption,
      Medications = input$Medications,
      PriorFractures = input$PriorFractures
    )
    
    # Corrected API URL
    api_url <- "http://127.0.0.1:8000/predict_logistic"
    
    # Make the API POST request
    response <- POST(api_url, body = inputs, encode = "json")
    
    # Parse the response
    if (response$status_code == 200) {
      result <- content(response, as = "parsed")
      output$prediction <- renderText({
        paste("Predicted Class: ", result$prediction)
      })
      output$probability <- renderText({
        paste("Probability of Osteoporosis: ", round(result$probability * 100, 2), "%")
      })
    } else {
      output$prediction <- renderText("Error: Could not connect to the API.")
      output$probability <- renderText("")
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
