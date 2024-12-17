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
      sliderInput("Age", "Age (years):", min = 18, max = 107, value = 45),  # Slider input for age
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
      selectInput("PriorFractures", "History of Prior Fractures:", choices = c("Yes", "No"))
    ),
    
    mainPanel(
      # Output fields for prediction results
      h3("Prediction Results"),
      htmlOutput("prediction"),  # Color-coded output
      verbatimTextOutput("probability")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Reactive expression to call the API when inputs change
  prediction_result <- reactive({
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
      
      # Extract the nested values properly
      probability <- as.numeric(result$probability[[1]])
      prediction <- as.character(result$prediction[[1]])
      
      list(probability = probability, prediction = prediction)
    } else {
      list(probability = NA, prediction = "Error: Could not connect to the API.")
    }
  })
  
  # Render color-coded prediction output
  output$prediction <- renderUI({
    result <- prediction_result()
    if (result$prediction == "Yes") {
      HTML(paste("<b style='color: red;'>Predicted Class: Yes</b>"))
    } else if (result$prediction == "No") {
      HTML(paste("<b style='color: green;'>Predicted Class: No</b>"))
    } else {
      HTML(paste("<b style='color: gray;'>", result$prediction, "</b>"))
    }
  })
  
  # Render the probability output
  output$probability <- renderText({
    result <- prediction_result()
    if (!is.na(result$probability)) {
      paste("Probability of Osteoporosis: ", round(result$probability * 100, 2), "%")
    } else {
      "Probability: Error in API response."
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
