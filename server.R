library(shiny)
library(shinymaterial)
library(reticulate)

# USER to keep track of user identity
USER <- reactiveValues(Logged = TRUE, ID = "CLIENT", Address = "0x5e81dA9C90B3ef86B3C2769633bA0946D715a2ad")

shinyServer <- function(input, output, session) {
  
  source('./util.R', local = TRUE)
  #source('./login.R',  local = TRUE)
  use_condaenv("chain")
  source_python("app.py")
  
#  set_rpc_address("http://localhost:8545")
  ##############################
  ## APP UI depending on ID
  ############################## 
  
  observe({
    if(USER$Logged == TRUE){
      if(USER$ID == "CLIENT"){
        init(USER$Address)
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