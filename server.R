library(shiny)
library(shinymaterial)
library(reticulate)
#system("eval \"source ./chain/bin/activate\"")
use_virtualenv('chain', required=TRUE)
source_python("app.py")
#system("source chain/bin/activate")/srv/connect/apps/webApp/chain/bin/python3
#Sys.setenv(RETICULATE_PYTHON = '/usr/bin/python3') 
#py_discover_config()
#system("virtualenv -p python3 chain")
#system("which python")
#system("ls")
#system("python3 -m ensurepip --default-pip")
#system("apt-get -y install python3-pip")
#system("python3.5 -m pip install web3")
# map <- vector("list", 3)
# map[1] <- "0x7Dc3600FE2823a113C5c5439E128ba6d3eA15A41"
# map[2] <- "0xd04F17fC0aef8417E4E487b69F35ACfA349d6Ca5"
# map[3] <- "0x98Bd15a5cC81774E0215C1a649C9d3A4c38345e6"
# map[4] <- "0x5e81dA9C90B3ef86B3C2769633bA0946D715a2ad"

# USER to keep track of user identity

shinyServer <- function(input, output, session) {
  z<-1
  source('./util.R', local = TRUE)
  #source('./login.R',  local = TRUE)
  #map <- usr()
  USER <- reactiveValues(Logged = TRUE, ID = z, Address = "b4b0316b7be9664ee5790f5afc1152e5df37eea929810f0bcb1b51118bb80c36")

  ##############################
  ## APP UI depending on ID
  ############################## 
  
  observeEvent(USER$Logged, {
    if(USER$Logged == TRUE){
      if(USER$ID == 4){
        init(USER$Address)
        source('./client.R', local = TRUE)
      } else if(USER$ID == 1) {
        init(USER$Address)
        source('./bank.R', local = TRUE)
      } else if(USER$ID == 2) {
        init(USER$Address)
        source('./police.R', local = TRUE)
      } else if(USER$ID == 3) {
        init(USER$Address)
        source('./garage.R', local = TRUE)
      } 
      else{ source('./void.R', local = TRUE)}   #Gag to be removed
      includeScript('./www/app.js', local = TRUE)
      
    }
  }) 
  
}