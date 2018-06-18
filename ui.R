# This is the test webapp for the blockchain insurance app.
# Summer project by Product Innovation intern Wen Quan Li.
# 2018-06
# TD Insurance

library(shiny)
library(shinymaterial)

material_page(
  tags$head(

    tags$link(rel = "stylesheet", type = "text/css", href = "C.css")
  ),
  title = "My Blockchain Portal",
  nav_bar_color = "green darken-1",
  background_color = "light-green",

  uiOutput("login"),
  
  ##############################
  ## Portal Page UI
  ############################## 
  uiOutput("page")
)



