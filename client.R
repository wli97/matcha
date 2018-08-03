##############################
## APP Init for CLIENT
##############################
past <- vector("list", 1)
current <- vector("list", 1)
# update process can be improved with index checker, no need to reload past data
update <- function(){
  i<-0
  j<-0
  past <<- vector("list", 1)
  current <<- vector("list", 1)
  while(TRUE){
    request <- getRequest(USER$Address,i)
    # if no institution associated, it is empty
    if(request[1] < 1) break 
    if(request[5] > 6){
      # if status is above 6, it is completed
      request <- formatRequest(request,i)
      i <- i+1L
      j <- j+1L
      past[[j]] <<- request
    } 
    else{
      request <- formatRequest(request,i)
      i <- i+1L
      current[[i-j]] <<- request
    }
  }
}
update()

##############################
## APP UI for CLIENT
############################## 

output$page <- renderUI({
  div(
    material_side_nav(
      fixed = TRUE,
      image_source = "img/tdb.PNG",
      material_side_nav_tabs(
        side_nav_tabs = c(
          "Current Claims" = "current"
          ,"Past Claims" = "history"
          ,"Q&A" = "qa"
        ),
        icons = c("monetization_on"
                  ,"insert_chart"
                  ,"question_answer"
        )
      )
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "current",
      material_card(
        material_row(
          shiny::tags$h5("Start a New Claim"),
          
          material_column(
            width = 8,
            material_dropdown(
              input_id = "Rtype",
              label = "Type of Claim",
              choices = c(
                "Automobile" = "auto",
                "Residential" = "home",
                "Fraud" = "f"
              ),
              color = "green"
            )
          ),
          material_column(
            tags$br(),
            width = 4,
            material_modal(
              modal_id = "initiate",
              button_text = "New Claim",
              button_icon = "note_add",
              title = "New Claim",
              floating_botton = TRUE,
              button_depth = 5,
              button_color = "green",
              display_button = TRUE,
              hr(),
              shiny::tags$h5("Incident details"),
              material_checkbox(
                input_id = "police",
                label = "Police Involved",
                initial_value = FALSE,
                color = "green"
              ),
              uiOutput("Rtype"),
              material_dropdown(
                input_id = "ctype",
                label = "Choose",
                choices = typelist(FALSE),
                selected = 0,
                multiple = FALSE
              ),
              br(),
              material_text_box(
                input_id = "desc",
                label = "Describe the incident in a few sentences.",
                color = "green"
              ),
              material_date_picker(
                input_id = "date",
                label = "Date of incident",
                color = "green"
              ),
              shiny::tags$h6("Claim Amount (Optional). Leave empty if the exact amount is unknown."),
              br(),
              material_row(
                material_column(
                  width = 3,
                  material_number_box(
                    input_id = "amount",
                    label = "Round to integer",
                    min_value = 0,
                    max_value = 30000000,
                    initial_value = 0,
                    color = "green"
                  )
                )
              ),
              actionButton("submit", "Submit Claim", icon("paper-plane"), 
                           style="color: #fff; background-color: #00B624; border-color: #2e6da4"),
              uiOutput("submitStatus")
            )
          )
        )
      ),
      searchRequest(current,"My Current Requests",FALSE),
      uiOutput("reqDetail")
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "history",
      searchRequest(past, "My Past Requests",TRUE),
      uiOutput("reqDetail1")
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "qa",
      c_material_parallax(
        './img/td_bank.jpg'
      ),
      qa()
    )
  )
})

##############################
## APP SERVER for CLIENT
############################## 

observeEvent(input$Rtype,{
  if(input$Rtype == "auto"){
    output$Rtype <- renderUI({
      material_checkbox(
        input_id = "garage",
        label = "Garage Involved",
        initial_value = FALSE,
        color = "green"
      )
    })
    update_material_dropdown(session,"ctype",value = 0, choices = typelist(FALSE))
  } else if(input$Rtype == "home"){
    output$Rtype <- renderUI({
      material_checkbox(
        input_id = "garage",
        label = "Home Repair Involved",
        initial_value = FALSE,
        color = "green"
      )
    })
    update_material_dropdown(session,"ctype",value = 0, choices = typelist(TRUE))
  }
})

observeEvent(input$submit, {
  if( input$date=="" | input$desc==""){
    output$submitStatus <- renderUI({
      div(h6("Please fill in all required information."), style="color:red")
    })
  }
  #test if empty is 0
  else if(!is.integer(input$amount) || (input$Rtype=="auto" && input$amount > 300000) || (input$amount>0 && input$amount<5)){
    output$submitStatus <- renderUI({
      div(h6("Amount entered is below your deductible or above covered amount."), style="color:red")
    })
  }
  else if((input$Rtype=="auto" && input$ctype >2) || (input$Rtype =="home" && (input$ctype!=0 && input$ctype<3))){
    output$submitStatus <- renderUI({
      div(h6("Please use the correct Automobile/House form for this claim type."), style="color:red")
    })
  }
  # else if(as.Date(input$date, format="%Y-%m-%d") > Sys.time()){
  #   output$submitStatus <- renderUI({
  #     div(h6("Accident date cannot be in the future."), style="color:red")
  #   })
  # }
  else{
    dateFormat <- as.Date(input$date,format = '%d %B, %Y')
    print(input$ctype)
    status <- 0
    if(input$police) status <- status+1
    if(input$garage) status <- status+2
    stat <- requestClaim(accounts[3], as.integer(input$ctype), status, paste0(dateFormat, ": ",input$desc," ","Claim amount: ", input$amount, ". "), input$amount)
    while(!is.integer(stat)){
      Sys.sleep(1)
    }
    if(stat > 0){
      update_material_checkbox(session, "police", value=FALSE)
      update_material_checkbox(session, "garage", value=FALSE)
      update_material_date_picker(session, "date", value="")
      update_material_dropdown(session, "ctype", value=0)
      update_material_text_box(session, "desc", value="")
      update_material_number_box(session, "amount", value=0)
      output$submitStatus <- renderUI({
        div(h6("Submission succeeded! Please allow a moment for update."), style="color: green")
      })
      update()
      update_material_dropdown(session, "req", value="NULL", choices=requests(current))
      update_material_dropdown(session, "reqP", value="NULL", choices=requests(past))
    }else{
      output$submitStatus <- renderUI({
        div(h6("Submission failed! Please try again later."), style="color: orange")
      })
    }
  }
})

observeEvent(input$det, {
  if(input$det > 0 && input$req != "NULL"){
    index <- as.integer(input$req)
    output$reqDetail <- renderUI({
      request(current[[index]])
    })
  }
  else{
    output$reqDetail <- renderUI({div()})
  }
})

observeEvent(input$detP, {
  if(input$detP > 0 && input$reqP != "NULL"){
    index <- as.integer(input$reqP)
    output$reqDetailP <- renderUI({
      request(past[[index]])
    })
  }
  else{
    output$reqDetailP <- renderUI({div()})
  }
})

observeEvent(input$req,{
  output$reqDetail <- renderUI({div()})
})

observeEvent(input$reqP,{
  output$reqDetailP <- renderUI({div()})
})