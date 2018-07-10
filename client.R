past <- c()
current <- c()

update <- function(){
  past <<- c()
  current <<- c()
  i<-0
  while(TRUE){
    request <- getRequest(myAddress,i)
    if(request[5] == 0) break # if no institution associated, it is empty
    i <- i+1
    if(request[4] > 6) past <<- c(past, request) # if status is above 6, it is completed
    else current <<- c(current, request) 
  }
}
update()
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
            width = 6,
            material_dropdown(
              input_id = "type",
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
            width = 6,
            material_modal(
              modal_id = "initiate",
              button_text = "New Claim",
              button_icon = "note_add",
              title = "New Claim",
              floating_botton = TRUE,
              button_depth = 5,
              button_color = "green darken-1",
              display_button = TRUE,
              
              material_checkbox(
                input_id = "police",
                label = "Police Involved",
                initial_value = FALSE,
                color = "green"
              ),
              uiOutput("type"),
              br(),
              shiny::tags$p("Incident details"),
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
              shiny::tags$p("Claim Amount (Optional)"),
              material_text_box(
                input_id = "amount",
                label = "Leave empty if the exact amount is unknown.",
                color = "green"
              ),
              g_actionLink(
                "submit",
                label = "Submit",
                color = "green"
              ),
              uiOutput("submitStatus")
            )
          )
        )),
      material_row(
        material_column(
          width = 12,
          material_card(
            title = "Current Claims in Process",
            tags$br(),
            shiny::tags$h6("Nothing in process, fortunately!")
          )
        )
      )
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "history"
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "qa",
      c_material_parallax(
        './img/td_bank.jpg'
      ),
      material_row(
        material_column(
          width = 12,
          material_card(
            title = "Current Claims in Process",
            tags$br(),
            shiny::tags$h6("Nothing in process, fortunately!")
          )
        )
      )
    )
  )
})


output$type <- renderUI({
  if(input$type== "auto"){
    material_checkbox(
      input_id = "garage",
      label = "Garage Involved",
      initial_value = FALSE,
      color = "green"
    )
  }else{
    material_checkbox(
      input_id = "garage",
      label = "Home Repair Involved",
      initial_value = FALSE,
      color = "green"
    )
  }
})

observeEvent(input$submit, {

  if( input$date=="" | input$desc==""){
    output$submitStatus <- renderUI({
      div(h6("Please fill in all required information."), style="color:red")
    })
  }
  else{
    dateFormat = as.Date(input$date,format = '%d %B, %Y')
    output$submitStatus <- renderUI({
      div(h6("Submission succeeded! Please allow a moment for update."), style="color: green")
    })
  }
})
