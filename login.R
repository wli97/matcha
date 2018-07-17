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
      USER$Address <- "0x5e81dA9C90B3ef86B3C2769633bA0946D715a2ad"
    } else if(input$usr == "police" & input$pwd == "police"){
      USER$ID <- "POLICE"
      USER$Logged <- TRUE
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

