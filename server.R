library(shiny)
library(shinymaterial)
library(reticulate)

Logged = FALSE
ID = NULL;
Address = 0x0;

shinyServer <- function(input, output, session) {
  
  source('./util.R', local = TRUE)
  source('./login.R',  local = TRUE)
  use_condaenv("chain")
  source_python("app.py")
  
#  set_rpc_address("http://localhost:8545")
  ##############################
  ## APP UI depending on ID
  ############################## 
  
  observe({
    if(USER$Logged == TRUE){
      if(USER$ID == "CLIENT"){
        me <- '0x7Dc3600FE2823a113C5c5439E128ba6d3eA15A41'
        init(me)
        source('./client.R', local = TRUE)
      } else if(USER$ID == "POLICE") {
        source('./police.R', local = TRUE)
      } else if(USER$ID == "FRAUD") {
        source('./garage.R', local = TRUE)
      } else if(USER$ID == "BANK") {
        source('./police.R', local = TRUE)
      }
      includeScript('./www/app.js', local = TRUE)
      
    }
  }) 
  
}