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
## Password Validation (To be changed)
############################## 

observeEvent(input$log, {
  if(input$usr != "" & input$pwd != ""){
    if(input$usr == "client" & input$pwd == "client"){
      USER$ID <- "CLIENT"
      USER$Logged <- TRUE
      USER$Address <- map[4]
    } else if(input$usr == "police" & input$pwd == "police"){
      USER$ID <- "POLICE"
      USER$Logged <- TRUE
      USER$Address <- map[2]
    } else if(input$usr == "garage" & input$pwd == "garage"){
      USER$ID <- "GARAGE"
      USER$Logged <- TRUE
      USER$Address <- map[3]
    } else if(input$usr == "bank" & input$pwd == "bank"){
      USER$ID <- "BANK"
      USER$Logged <- TRUE
      USER$Address <- map[1]
    } else if(input$usr == "fraud" & input$pwd == "fraud"){
      USER$ID <- "FRAUD"
      USER$Logged <- TRUE
    }
    else{
      output$loginFail <- renderUI(
        div(h6("Wrong password/ID combination."), style="color:red")
      )
    }
  }
})

