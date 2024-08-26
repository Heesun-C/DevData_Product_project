#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(caret)
library(xgboost)

# Load the pre-trained model
final_xgb_model <- readRDS("final_diabetes_xgb_model.rds")

server <- function(input, output, session) {
  
  # Reactive expression for prediction
  prediction <- eventReactive(input$predict, {
    # Create a data frame with user inputs
    new_data <- data.frame(
      HighBP = as.factor(input$highbp),
      HighChol = as.factor(input$highchol),
      BMI = input$bmi,
      DiffWalk = as.factor(input$diffwalk),
      GenHlth = as.factor(input$genhlth)
    )
    
    # Make prediction (including probabilities)
    pred <- predict(final_xgb_model, newdata = new_data, type = "prob")
    
    # Get the predicted class
    pred_class <- colnames(pred)[max.col(pred)]
    
    # Calculate confidence score (probability of the predicted class)
    confidence_score <- max(pred)
    
    # Prepare the result
    result <- list(
      class = pred_class,
      confidence = confidence_score,
      main_text = switch(pred_class,
                         "Normal" = "Normal",
                         "Prediabetes" = "Prediabetes",
                         "Diabetes" = "Diabetes",
                         "Unable to determine"
      ),
      sub_text = switch(pred_class,
                        "Normal" = "You are classified as having Normal risk for diabetes.",
                        "Prediabetes" = "You are classified as having Prediabetes risk. It's recommended to consult with a healthcare provider.",
                        "Diabetes" = "You are classified as having high risk for Diabetes. It's strongly recommended to consult with a healthcare provider.",
                        "Unable to determine risk category. Please check your inputs and try again."
      )
    )
    
    return(result)
  })
  
  # Output prediction result
  output$result_main <- renderText({
    pred <- prediction()
    pred$main_text
  })
  
  output$result_sub <- renderText({
    pred <- prediction()
    pred$sub_text
  })
  
  output$confidence <- renderText({
    pred <- prediction()
    sprintf("Confidence Score: %.2f%%", pred$confidence * 100)
  })
}