library(shiny)
library(shinymaterial)

Logged = FALSE
ID = NULL;

shinyServer <- function(input, output) {
  
  source('./util.R', local = TRUE)
  source('./login.R',  local = TRUE)
  
  ##############################
  ## APP UI depending on ID
  ############################## 
  
  observe({
    if(USER$Logged == TRUE){
      if(USER$ID == "CLIENT"){
        source('./client.R', local = TRUE)
      } else if(USER$ID == "POLICE") {
        source('./police.R', local = TRUE)
      } else if(USER$ID == "GARAGE") {
        source('./police.R', local = TRUE)
      } else if(USER$ID == "BANK") {
        source('./police.R', local = TRUE)
      }
    }
  }) 
  
  
}