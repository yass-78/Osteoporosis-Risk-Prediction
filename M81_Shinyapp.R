# Load required libraries
library(shiny)
library(shinythemes)
library(DT)
library(shinycssloaders)
library(httr)
library(jsonlite)
library(shinyjs)

# Define the UI
ui <- fluidPage(
  useShinyjs(),  # Initialize shinyjs for enabling/disabling
  theme = shinytheme("flatly"),  # Use a light theme for styling
  tags$head(
    tags$style(HTML("
      .hero {
        background-color: #00274D;  /* Dark blue for header */
        color: white;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .logos {
        display: flex;
        gap: 15px;  /* Space between logos */
      }
      footer {
        position: fixed;
        bottom: 0;
        left: 0;
        width: 100%;
        background-color: #00274D;  /* Dark blue for footer */
        color: white;
        text-align: center;
        padding: 10px;
        font-size: 14px;
      }
    "))
  ),
  
  # Header Section
  div(class = "hero",
      h1("Osteoporosis Prediction App"),
      div(class = "logos",
          tags$img(src = "ub_logo.png", height = "110px"),  # University of Barcelona logo
          tags$img(src = "upc_logo.png", height = "100px")  # UPC logo
      )
  ),
  
  # Add tabs to switch between live prediction and batch prediction
  tabsetPanel(
    # Tab 1: Live Prediction
    tabPanel("Live Prediction",
             sidebarLayout(
               sidebarPanel(
                 h4("Enter Data for a Single Prediction:"),
                 sliderInput("Age", "Age (years):", min = 18, max = 107, value = 45),
                 
                 radioButtons("Gender", "Gender:",
                              choices = c("Male", "Female"), 
                              inline = TRUE),
                 
                 radioButtons("HormonalChanges", "Hormonal Changes:",
                              choices = c("Normal", "Postmenopausal"), 
                              inline = TRUE),
                 
                 radioButtons("FamilyHistory", "Family History of Osteoporosis:",
                              choices = c("Yes", "No"), 
                              inline = TRUE),
                 
                 selectInput("RaceEthnicity", "Race/Ethnicity:",
                             choices = c("Caucasian", "Asian", "African American")),
                 
                 radioButtons("BodyWeight", "Body Weight:",
                              choices = c("Normal", "Underweight"), 
                              inline = TRUE),
                 
                 radioButtons("CalciumIntake", "Calcium Intake Level:",
                              choices = c("Low", "Adequate"), 
                              inline = TRUE),
                 
                 radioButtons("VitaminDIntake", "Vitamin D Intake Level:",
                              choices = c("Sufficient", "Insufficient"), 
                              inline = TRUE),
                 
                 radioButtons("PhysicalActivity", "Physical Activity Level:",
                              choices = c("Sedentary", "Active"), 
                              inline = TRUE),
                 
                 radioButtons("Smoking", "Smoking Status:",
                              choices = c("Yes", "No"), 
                              inline = TRUE),
                 
                 radioButtons("AlcoholConsumption", "Alcohol Consumption Level:",
                              choices = c("Moderate", "None"), 
                              inline = TRUE),
                 
                 radioButtons("Medications", "Medications:",
                              choices = c("Corticosteroids", "None"), 
                              inline = TRUE),
                 
                 radioButtons("PriorFractures", "History of Prior Fractures:",
                              choices = c("Yes", "No"), 
                              inline = TRUE)
               ),
               mainPanel(
                 h3("Prediction Results"),
                 htmlOutput("single_prediction"),
                 verbatimTextOutput("single_probability")
               )
             )
    ),
    
    # Tab 2: CSV Upload and Batch Prediction
    tabPanel("Batch Prediction",
             sidebarLayout(
               sidebarPanel(
                 h4("Upload a CSV File for Batch Predictions"),
                 fileInput("file_upload", "Upload CSV File", accept = c(".csv")),
                 actionButton("process_csv", "Process CSV"),
                 downloadButton("download_predictions", "Download Results as CSV", disabled = TRUE)
               ),
               mainPanel(
                 h3("Batch Prediction Results"),
                 DT::dataTableOutput("batch_results") %>% withSpinner(color = "#007bff")
               )
             )
    )
  ),
  
  # Footer Section
  tags$footer(
    HTML("Developed by <b>The Random Group</b>. Powered by Shiny."),
    style = "position:fixed; bottom:0; left:0; width:100%;"
  )
)

# Define the server logic
server <- function(input, output, session) {
  
  # Function to send API request for a single row of data
  predict_single <- function(data) {
    api_url <- "http://127.0.0.1:8000/predict_logistic"
    response <- POST(api_url, body = data, encode = "json")
    if (response$status_code == 200) {
      result <- content(response, as = "parsed")
      list(probability = as.numeric(result$probability[[1]]),
           prediction = as.character(result$prediction[[1]]))
    } else {
      list(probability = NA, prediction = "Error")
    }
  }
  
  # Reactive to store batch data
  batch_data <- reactiveVal()
  
  # Process CSV when the button is clicked
  observeEvent(input$process_csv, {
    req(input$file_upload)
    df <- read.csv(input$file_upload$datapath)
    predictions <- lapply(1:nrow(df), function(i) {
      predict_single(as.list(df[i, ]))
    })
    df$Prediction <- sapply(predictions, function(x) x$prediction)
    df$Probability <- sapply(predictions, function(x) round(x$probability * 100, 2))
    batch_data(df)
    shinyjs::enable("download_predictions")  # Enable download button after processing
  })
  
  # Render batch results table
  output$batch_results <- DT::renderDataTable({
    req(batch_data())
    DT::datatable(batch_data(), options = list(pageLength = 5))
  })
  
  # Disable download button by default
  observe({
    if (is.null(input$file_upload)) {
      shinyjs::disable("download_predictions")
    }
  })
  
  # Download Handler
  output$download_predictions <- downloadHandler(
    filename = function() {
      "osteoporosis_predictions.csv"
    },
    content = function(file) {
      req(batch_data())
      write.csv(batch_data(), file, row.names = FALSE)
    }
  )
  
  # Single Prediction Logic
  single_result <- reactive({
    data <- list(
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
    predict_single(data)
  })
  
  output$single_prediction <- renderUI({
    result <- single_result()
    if (result$prediction == "Yes") {
      HTML(paste("<b style='color: red;'>Predicted Class: Yes</b>"))
    } else if (result$prediction == "No") {
      HTML(paste("<b style='color: green;'>Predicted Class: No</b>"))
    }
  })
  
  output$single_probability <- renderText({
    result <- single_result()
    if (!is.na(result$probability)) {
      paste("Probability of Osteoporosis: ", round(result$probability * 100, 2), "%")
    } else {
      "Probability: Error in API response."
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
