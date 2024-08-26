#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = "Diabetes Prediction App"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Prediction", tabName = "prediction", icon = icon("dashboard")),
      menuItem("Help", tabName = "help", icon = icon("question-circle"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "prediction",
              fluidRow(
                box(
                  title = "About This App",
                  HTML("
                    <p>This app predicts the likelihood of diabetes based on health indicators. 
                    Enter your health information in the fields below and click 'Predict' to see your results.</p>
                    
                    <p>The model used in this app was developed using a 20% stratified sample of the 'Diabetes Health Indicators Dataset' 
                    from Kaggle (<a href='https://www.kaggle.com/datasets/alexteboul/diabetes-health-indicators-dataset/data' target='_blank'>link to dataset</a>). 
                    We employed XGBoost, a powerful machine learning algorithm, to create our predictive model.</p>
                    
                    <p>The stratified sampling ensures that the proportions of Normal, Prediabetes, and Diabetes cases in our 
                    training data are representative of the full dataset, while allowing for faster model training and deployment.</p>
                    
                    <p><strong>Please note:</strong> While this app is based on real data and uses advanced modeling techniques, 
                    it is intended for educational purposes only and should not be used as a substitute for 
                    professional medical advice.</p>
                  "),
                  status = "info",
                  solidHeader = TRUE,
                  width = 12
                )
              ),
              fluidRow(
                box(
                  title = "Input Values",
                  numericInput("bmi", "BMI (Body Mass Index):", value = 25, min = 10, max = 50),
                  
                  tags$label("Have you been told by a health care provider that you have high blood pressure?"),
                  selectInput("highbp", NULL, choices = c("No" = 0, "Yes" = 1)),
                  
                  tags$label("Have you EVER been told by a health care provider that your blood cholesterol is high?"),
                  selectInput("highchol", NULL, choices = c("No" = 0, "Yes" = 1)),
                  
                  tags$label("Do you have serious difficulty walking or climbing stairs?"),
                  selectInput("diffwalk", NULL, choices = c("No" = 0, "Yes" = 1)),
                  
                  tags$label("Would you say that in general your health is:"),
                  selectInput("genhlth", NULL, 
                              choices = c("Excellent" = 1, "Very Good" = 2, "Good" = 3, "Fair" = 4, "Poor" = 5)),
                  
                  actionButton("predict", "Predict")
                ),
                box(
                  title = "Prediction Result",
                  tags$h3(textOutput("result_main"), style = "font-weight: bold;"),
                  tags$p(textOutput("result_sub")),
                  tags$p(textOutput("confidence"), style = "font-weight: bold;"),
                  tags$br(),
                  tags$small(
                    "Note: The Confidence Score represents how certain the model is about this specific prediction. 
              A higher score indicates greater confidence, but it does not guarantee accuracy. 
              Always consult with a healthcare professional for medical advice."
                  )
                )
              )
      ),
      tabItem(tabName = "help",
              fluidRow(
                box(
                  title = "How to Use This App",
                  HTML("
                    <ol>
                      <li>Enter your health information in the 'Input Values' section.</li>
                      <li>Click the 'Predict' button to see your results.</li>
                      <li>The app will display your predicted diabetes risk category along with a Confidence Score.</li>
                      <li>The Confidence Score indicates how certain the model is about its prediction for your specific inputs.</li>
                      <li>Remember that this model was trained on a 20% sample of the original dataset, which may affect its performance.</li>
                      <li>This app is for educational purposes only. Always consult with a healthcare professional for medical advice.</li>
                    </ol>
                  "),
                  status = "info",
                  solidHeader = TRUE,
                  width = 12
                )
              )
      )
    )
  )
)