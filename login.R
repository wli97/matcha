# list of ganache genrated private-key as test users. you can import more using ganache.
map <- vector("list", 3)
map[[1]] <- "963fd9f33a18300d0d2809c4e6870861b98d8d7680e4a3ddbfd34de01d8b3cc4"
map[[2]]<- "f5d26d69b9c56bba63c22695f25d23515ab48abe25dda73dc0d18b4d274f266f"
map[[3]] <- "d9a9e4daccfd8d016fa9d714fb53fa6b17da8a17cf0ad5bc3d5e865a737120e2"
map[[4]] <- "d8f42662cd639e2ebdaf84bb5ebbec048e76072fa06d6b63f04458118ded7933"
# USER to keep track of user identity "b4b0316b7be9664ee5790f5afc1152e5df37eea929810f0bcb1b51118bb80c36" private key

##############################
## Login UI
############################## 

observe({
  if(USER$Logged == FALSE){
    output$login <- renderUI({
      material_card(
        material_text_box(
          input_id = "usr",
          label = "Enter Username:",
          color = "green"
        ),
        material_password_box(
          input_id = "pwd",
          label = "Enter Password:",
          color = "green"
        ),
        material_button(
          input_id = "log",
          label = "Log In",
          color = "green"
        ),
        uiOutput("loginFail")
      )
    })
  }else{
    output$login <- renderUI({ invisible() })
  }
})

##############################
## Password Validation (Placeholder for prototype, to be improved)
############################## 

observeEvent(input$log, {
  if(input$usr != "" & input$pwd != ""){
    if(input$usr == "client" & input$pwd == "client"){
      USER$ID <- 4
      USER$Logged <- TRUE
      USER$Key <- map[[4]]
    } else if(input$usr == "police" & input$pwd == "police"){
      USER$ID <- 2
      USER$Logged <- TRUE
      USER$Key <- map[[2]]
    } else if(input$usr == "garage" & input$pwd == "garage"){
      USER$ID <- 3
      USER$Logged <- TRUE
      USER$Key <- map[[3]]
    } else if(input$usr == "bank" & input$pwd == "bank"){
      USER$ID <- 1
      USER$Logged <- TRUE
      USER$Key <- map[[1]]
    } else if(input$usr == "fraud" & input$pwd == "fraud"){
      USER$ID <- 0
      USER$Logged <- TRUE
    }
    else{
      output$loginFail <- renderUI(
        div(h6("Wrong password/ID combination."), style="color:red")
      )
    }
  }
})

