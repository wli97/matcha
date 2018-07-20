##############################
## APP Init for CLIENT
##############################
autoInvalidate <- reactiveTimer(5000, session)
past <- vector("list", 1)
current <- vector("list", 1)
# update process can be improved with index checker, no need to reload past data
update <- function(){
  i<-0
  j<-0
  while(TRUE){
    request <- getRequest(USER$Address,i)
    # if no institution associated, it is empty
    if(request[1] < 1) break 
    if(request[4] > 6){
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
  autoInvalidate()
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
              hr(),
              shiny::tags$h5("Incident details"),
              material_checkbox(
                input_id = "police",
                label = "Police Involved",
                initial_value = FALSE,
                color = "green"
              ),
              uiOutput("type"),
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
              g_actionLink(
                "submit",
                label = "Submit",
                color = "green"
              ),
              uiOutput("submitStatus")
            )
          )
        )
      ),
      if(is.null(current[[1]])){
        material_row(
          material_column(
            width = 6,
            material_card(
              h5("No claim currently in process, fortunately!")
            )
          )
        )
      }
      else{
        lapply(1:length(current), function(i) {
          request(paste0("cReq",i), paste0("Request #",i, " on ", current[[i]][[1]]),current[[i]])
        })
      }
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "history",
      material_card(
        h5("Past Claim Requests"),
        material_row(
          material_column(
            width = 3,
            material_button(
              input_id = "upd",
              label = "Refresh",
              depth = 5,
              icon = "refresh",
              color = "green"
            )
          )
        )
      ),
      if(is.null(past[[1]])){
        material_row(
          material_column(
            width = 12,
            material_card(
              h5("Nothing in records, fortunately!")
            )
          )
        )
      }
      else{
        lapply(1:length(past), function(i) {
          request(paste0("pReq",i), paste0("Request #",i, " on ", past[[i]][[1]]),past[[i]])
        })
      }
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "qa",
      c_material_parallax(
        './img/td_bank.jpg'
      )
    )
  )
})

##############################
## APP SERVER for CLIENT
############################## 

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
  else if(!is.integer(input$amount) || (input$type=="auto" && input$amount > 300000) || (input$amount>0 && input$amount<5)){
    output$submitStatus <- renderUI({
      div(h6("Invalid input, or unrealistic claim amount."), style="color:red")
    })
  }
  else{
    dateFormat <- as.Date(input$date,format = '%d %B, %Y')
    status <- 0
    if(input$police) status <- status+1
    if(input$garage) status <- status+2
    stat <- requestClaim(accounts[3], status, paste0(dateFormat, ": ",input$desc, " Claim amount: ", input$amount, ". "))
    if(stat > 0){
      update_material_checkbox(session, "police", value=FALSE)
      update_material_checkbox(session, "garage", value=FALSE)
      update_material_date_picker(session, "date", value="")
      update_material_text_box(session, "desc", value="")
      update_material_number_box(session, "amount", value=0)
      output$submitStatus <- renderUI({
        div(h6("Submission succeeded! Please allow a moment for update."), style="color: green")
      })
    }else{
      output$submitStatus <- renderUI({
        div(h6("Submission failed! Please try again later."), style="color: orange")
      })
    }
    update()
  }
})

observeEvent(input$upd, {
    update()
})