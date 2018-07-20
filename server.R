library(shiny)
library(shinymaterial)
library(reticulate)

# map <- vector("list", 3)
# map[1] <- "0x7Dc3600FE2823a113C5c5439E128ba6d3eA15A41"
# map[2] <- "0xd04F17fC0aef8417E4E487b69F35ACfA349d6Ca5"
# map[3] <- "0x98Bd15a5cC81774E0215C1a649C9d3A4c38345e6"
# map[4] <- "0x5e81dA9C90B3ef86B3C2769633bA0946D715a2ad"

# USER to keep track of user identity

shinyServer <- function(input, output, session) {
  
  source('./util.R', local = TRUE)
  #source('./login.R',  local = TRUE)
  use_condaenv("chain")
  source_python("app.py")
  map <- usr()
  USER <- reactiveValues(Logged = TRUE, ID = "BANK", Address = map[1])
  
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
      } else if(USER$ID == "GARAGE") {
        source('./garage.R', local = TRUE)
        init(USER$Address)
      } else if(USER$ID == "BANK") {
        source('./bank.R', local = TRUE)
      }
      else{ source('./void.R', local = TRUE)}   #Gag to be removed
      includeScript('./www/app.js', local = TRUE)
      
    }
  }) 
  
}