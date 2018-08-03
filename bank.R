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
    # if(request[4] != 6){
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
          "Current Claims" = "current"
          ,"Search Client" = "history"
          ,"Fund Money" = "qa"
        ),
        icons = c("monetization_on"
                  ,"insert_chart"
                  ,"payment"
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
            h5("Search Client")
          )
        ),
        material_row(
          material_column(
            width = 5,
            material_text_box(
              input_id = "CAddress",
              label = "Address of the client",
              color = "green"
            )
          ),
          material_column(
            width = 2,
            material_button(
              input_id = "getC",
              label = "Search!",
              color = "green",
              depth = 5
            )
          ),
          material_column(
            width = 3,
            material_dropdown(
              input_id = "Ctype",
              label = "Type",
              color = "green",
              choices = c(
                "Client" = 4,
                "Police" = 2,
                "Repair" = 3
              )
            )
          ),
          material_column(
            width = 2,
            material_button(
              input_id = "AddC",
              label = "Add!",
              color = "amber",
              depth = 5
            )
          )
        )
      ),
      uiOutput("clientReq")
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "qa",
      material_parallax(
        './img/td_bank.jpg'
      ),
      material_card(
        h5("Fund Money to Matcha"),
        material_button(
          input_id = "fund",
          label = "Fund Matcha!",
          color = "amber"
        ),
        material_button(
          input_id = "check",
          label = "Balance",
          color = "green"
        ),
        br(),
        uiOutput("msg")
      )
    )
  )
})

##############################
## APP SERVER for BANK
############################## 

observeEvent(input$det, {
  if(input$det > 0 && input$req != "NULL"){
    index <- as.integer(input$req)
    output$reqDetail <- renderUI({
      request(current[[index]],material_row(
        material_column(width=5, material_text_box(
          input_id = "validA", 
          label = "Optional: append any justification.",
          color = "green"
        )),
        material_column(width=3, material_number_box(
          input_id = "validD",
          label = "Payment Amount",
          initial_value = 0,
          min_value = 0,
          max_value = 1000000,
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
    resp <- payClaim(current[[as.integer(input$req)]][[9]], TRUE, paste0("BK ",": ",Sys.time(),"-",input$validA), input$validD)
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
    resp <- payClaim(current[[as.integer(input$req)]][[9]], FALSE, paste0("BK ",": ",Sys.time(),"-",input$validA),input$validD)
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

observeEvent(input$fund, {
  if(input$fund >0 && inject() > 0){
    output$msg <- renderUI({
      div(h6("Injection Successful."), style="color:green")
    })
  } else{
    output$msg <- renderUI({
      div(h6("Injection Failed."), style="color:red")
    })
  }
})

observeEvent(input$check, {
  f <- checkFund()
  #test()
  output$msg <- renderUI({
    div(h5("Amount: ", f, " Ether. "), style="color:green")
  })
})
observeEvent(input$getC, {
  client <- getClient(input$CAddress)
  if( is.null(client) ){
    output$clientReq <- renderUI({
      material_card(h5("Client does not exist, or access denied."))
    })
  } else{
    output$clientReq <- renderUI({
      div(
        lapply(1:length(client), function(i) {
          request(client[[i]])
        })
      )
    })
  }
})



getClient <- function(address){
  client <- vector("list", 1)
  i <- 0
  while(TRUE){
    request <- getRequest(address, i)
    if(request[[1]] < 1) break
    request <- formatRequest(request, i)
    i <- i+1
    client[[i]] <- request
  }
  if(i == 0) return()
  return(client)
}