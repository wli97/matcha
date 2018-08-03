current <- vector("list", 1)
# update process can be improved with index checker, no need to reload past data
update <- function(){
  i<-0L
  current <<- vector("list", 1)
  while(TRUE){
    valid <- getValid(USER$Address,i)
    if(length(valid) <= 1) break
    request <- getRequest(valid[[1]], valid[[2]])
    # if no timestamp, it is empty
    if(request[1] < 1) break
    request <- formatRequest(request,i)
    i <- i+1L
    current[[i]] <<- request
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
          "Client Claims" = "current"
          ,"Your Claims" = "history"
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
      searchRequest(current,"Current Client Requests",FALSE),
      uiOutput("reqDetail")
    ),

    material_side_nav_tab_content(
      side_nav_tab_id = "history",
      material_card(
        material_row(
          material_column(
            width = 6,
            h5("Past Claims")
          )
        )
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
## APP SERVER for GARAGE
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
    resp <- validate(current[[as.integer(input$req)]][[9]], TRUE, paste0("RS ",": ",Sys.time(),"-",input$validA))
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
    resp <- validate(current[[as.integer(input$req)]][[9]], FALSE, paste0("RS ",": ",Sys.time(),"-",input$validA))
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

# observe(input$submit, {
#   if( input$date=="" | input$desc==""){
#     output$submitStatus <- renderUI({
#       div(h6("Please fill in all required information."), style="color:red")
#     })
#   }
#   else if(!is.integer(input$amount) || (input$type=="auto" && input$amount > 300000) || (input$amount>0 && input$amount<5)){
#     output$submitStatus <- renderUI({
#       div(h6("Invalid input, or unrealistic claim amount."), style="color:red")
#     })
#   }
#   else{
#     dateFormat <- as.Date(input$date,format = '%d %B, %Y')
#     status <- 0
#     if(input$police) status <- status+1
#     if(input$garage) status <- status+2
#     stat <- requestClaim(accounts[3], status, paste0(dateFormat, ": ",input$desc, " Claim amount: ", input$amount, ". "))
#     if(stat > 0){
#       update_material_checkbox(session, "police", value=FALSE)
#       update_material_checkbox(session, "garage", value=FALSE)
#       update_material_date_picker(session, "date", value="")
#       update_material_text_box(session, "desc", value="")
#       update_material_number_box(session, "amount", value=0)
#       output$submitStatus <- renderUI({
#         div(h6("Submission succeeded! Please allow a moment for update."), style="color: green")
#       })
#     }else{
#       output$submitStatus <- renderUI({
#         div(h6("Submission failed! Please try again later."), style="color: orange")
#       })
#     }
#     update()
#   }
# })
