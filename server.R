library(shiny)
library(shinymaterial)
library(reticulate)
use_condaenv("matcha", required=TRUE)
source_python("app.py")
#system("source chain/bin/activate")/srv/connect/apps/webApp/chain/bin/python3
#Sys.setenv(RETICULATE_PYTHON = '/usr/bin/python3') 
#system("python3 -m ensurepip --default-pip")
#system("python3.5 -m pip install web3")


shinyServer <- function(input, output, session) {
  USER <- reactiveValues(Logged = FALSE, ID = 0, Address = 0, Key = 0)
  source('./util.R', local = TRUE)
  source('./login.R',  local = TRUE)

  ##############################
  ## APP UI depending on ID
  ############################## 
  observeEvent(USER$Logged, {
    if(USER$Logged == TRUE){
      if(USER$ID == 4){
        USER$Address <<- init(USER$Key)
        source('./client.R', local = TRUE)
      } else if(USER$ID == 1) {
        USER$Address <<- init(USER$Key)
        source('./bank.R', local = TRUE)
      } else if(USER$ID == 2) {
        USER$Address <<- init(USER$Key)
        source('./police.R', local = TRUE)
      } else if(USER$ID == 3) {
        USER$Address <<- init(USER$Key)
        source('./garage.R', local = TRUE)
      } 
      else{ source('./void.R', local = TRUE)}   #Gag to be removed
      includeScript('./www/app.js', local = TRUE)
      
    }
  }) 
  
}