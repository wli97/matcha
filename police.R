current <- vector("list", 1)
# update process can be improved with index checker, no need to reload past data
# update <- function(){
#   i<-0L
#   j<-0L
#   while(TRUE){
#     valid <- getValid(USER$Address,i)
#     if(length(valid) <= 1) break
#     request <- getRequest(valid[[1]], valid[[2]])
#     # if no timestamp, it is empty
#     if(request[1] < 1) break
#     if(request[4] > 5 || request[4]==4){
#       # if status is above 6, it is completed
#       request <- formatRequest(request,i)
#       i <- i+1L
#       j <- j+1L
#       past[[j]] <<- request
#     } 
#     else{
#       request <- formatRequest(request,i)
#       i <- i+1L
#       current[[i-j]] <<- request
#     }
#   }
# }

update <- function(){
  i<-0L
  current <<- vector("list", 1)
  while(TRUE){
    valid <- getValid(USER$Address,i)
    if(length(valid) <= 1) break
    request <- getRequest(valid[[1]], valid[[2]])
    # if no timestamp, it is empty
    if(request[1] < 1) break
    # if(request[4] != 6){
    request <- formatRequest(request,i)
    i <- i+1L
    current[[i]] <<- request 
  }
}
update()

##############################
## APP UI for POLICE
##############################
output$page <- renderUI({
  div(
    material_side_nav(
      fixed = TRUE,
      image_source = "img/tdb.PNG",
      tags$div(h5("Police Portal"),align="center"),
      material_side_nav_tabs(
        side_nav_tabs = c(
          "Current Claims" = "current"
          ,"Industry Average" = "history"
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
      searchRequest(current,"Current Requests",FALSE),
      uiOutput("reqDetail")
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "history",
      material_card(
        material_row(
          material_column(
            width = 6,
            h5("Set Up Industry Averages")
          )
        ),
        material_dropdown(
          input_id = "ctype",
          label = "Choose type of incident",
          choices = typelist(2),
          color = "green"
        ),
        material_number_box(
          input_id = "amt",
          label = "Amount to be set",
          min_value = 1,
          max_value = 9999999,
          initial_value = "",
          color = "green"
        ),
        material_row(
          material_column(
            actionButton("AS average", "average", icon("equals"), 
                         style="color: #fff; background-color: #00B624")
          ),
          material_column(
            actionButton("std", "As standard deviation", icon("less-than"), 
                         style="color: #fff; background-color: #FFCC00")
          )
        ),
        uiOutput("updateStat")
      )
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
            title = "How to approve a request?",
            tags$br(),
            shiny::tags$h6("Click on green check button.")
          )
        )
      )
    )
  )
})

##############################
## APP SERVER for POLICE
##############################

observeEvent(input$det, {
  if(input$det > 0 && input$req != "NULL"){
    index <- as.integer(input$req)
    output$reqDetail <- renderUI({
      request(current[[index]],material_row(
        material_column(width=8, material_text_box(
          input_id = "validA", 
          label = "Optional: append any justification.",
          color = "green"
        )),
        actionButton("validB", "Valid", icon("check"), 
                     style="color: #fff; background-color: #00B624; border-color: #2e6da4"),
        actionButton("validC", "Invalid", icon("times"), 
                     style="color: #fff; background-color: red; border-color: #2e6da4"),
        uiOutput("submitStat")
      ))
    })
    output$submitStat <- renderUI({div()})
  }
  else{
    output$reqDetail <- renderUI({div()})
    output$valid <- renderUI({div()})
  }
})

observeEvent(input$req,{
  output$reqDetail <- renderUI({div()})
  output$valid <- renderUI({div()})
  output$submitStat <- renderUI({div()})
})

observeEvent(input$validB, {
  if(input$validB < 1){} else{  
    resp <- validate(current[[as.integer(input$req)]][[9]], TRUE, paste0(" PO ",": ",Sys.time(),"-",input$validA))
    if(resp == 0){
      output$submitStat <- renderUI({
        div(h6("Validation failed, please try again later."), style="color:red")
      })
    }
    else{
      update_material_text_box(session, "desc", value="")
      output$reqDetail <- renderUI({div()})
      update()
      update_material_dropdown(session,"req",value="NULL",choices=requests(current))
    }      
  }
})

observeEvent(input$validC, {
  if(input$validC < 1){} else{
    resp <- validate(current[[as.integer(input$req)]][[9]], FALSE, paste0("PO ",": ",Sys.time(),"-",input$validA))
    if(resp == 0){
      output$submitStat <- renderUI({
        div(h6("Validation failed, please try again later."), style="color:red")
      })
    }
    else{
      update_material_text_box(session, "desc", value="")
      output$reqDetail <- renderUI({div()})
      update()
      update_material_dropdown(session,"req",value="NULL",choices=requests(current))
    }}      
})

observeEvent(input$average, {
  if(input$average < 1){} else{
    resp <- setAvg(as.integer(input$ctype), as.integer(input$amt))
    if(resp == 0){
      output$updateStat <- renderUI({
        div(h6("Value update failed"), style="color:red")
      })
    }
    else{
      update_material_number_box(session, "amt", value="")
      output$updateStat <- renderUI({
        div(h6("New value update successfull"), style="color:green")
      })
    }
  }   
})

observeEvent(input$std, {
  if(input$average < 1){} else{
    resp <- setSd(as.integer(input$ctype), as.integer(input$amt))
    if(resp == 0){
      output$updateStat <- renderUI({
        div(h6("Value update failed"), style="color:red")
      })
    }
    else{
      update_material_number_box(session, "amt", value="")
      output$updateStat <- renderUI({
        div(h6("New value update successfull"), style="color:green")
      })
    }
  }   
})