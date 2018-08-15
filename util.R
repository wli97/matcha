c_material_parallax <-function(image_source, 
                               style = "height:300px", 
                               ...){
  
  div(material_parallax(
    image_source = image_source
  ),style= style, class="parallax-container", ...)
  
}

formatRequest <- function(request, index){
  request[[1]] <- as.POSIXct(request[[1]], origin="1970-01-01")
  request[[2]] <- "SPVM"
  request[[3]] <- "Garage TD"
  if(request[[4]] == 1) request[[4]] <- "Car Loss/Destruction"
  else if(request[[4]] == 2) request[[4]] <- "Car Rear Mirror Damage"
  else if(request[[4]] == 3) request[[4]] <- "House Water Damage"
  else if(request[[4]] == 4) request[[4]] <- "House Burnt Down/Total Destruction"
  else if(request[[4]] == 0) request[[4]] <- "Other"
  if(request[[5]] == 1) request[[5]] <- "Waiting for Police validation..."
  else if(request[[5]] == 2) request[[5]] <- "Waiting for Repair Shop validation..."
  else if(request[[5]] == 3) request[[5]] <- "Waiting for Police & Repair Shop validation..."
  else if(request[[5]] == 4) request[[5]] <- "Police validation completed. Now waiting for Repair shop..."
  else if(request[[5]] == 5) request[[5]] <- "Repair shop validation completed. Now waiting for Police..."
  else if(request[[5]] == 6) request[[5]] <- "Validations completed. Now waiting for payment..."
  else if(request[[5]] == 7) request[[5]] <- "Police rejected your request."
  else if(request[[5]] == 8) request[[5]] <- "Repair shop rejected your request."
  else if(request[[5]] == 9) request[[5]] <- "Your institution rejected your request."
  else if(request[[5]] == 10) request[[5]] <- "Payment sent from the institution."
  request[[6]] <- "TDI"
  request[[9]] <- index
  return(request)
}

typelist <- function(boo){
  if(boo){
    return(c(
      "Other" = 0,
      "House Water Damage" = 3,
      "House Burnt Down/Total Destruction" = 4
    ))
  }else{
  return(c(
    "Other" = 0,
    "Car Loss/Destruction" = 1,
    "Car Rear Mirror Damage" = 2
  ))
  }
}

requests <- function(cur){
  clist <- vector("list", 1)
  for(i in 1:length(cur)){
    clist[[paste0("Request #",i," -",cur[[i]][[1]])]] <- i
  }
  return(clist)
}

request <- function(info, ... ){
  div(
    material_card(
      h5("Request Details"),
      hr(),
      paste0("Time requested: ", info[[1]]), br(),
      paste0("Police: ", info[[2]]), br(),
      paste0("Repair Shop: ", info[[3]]), br(),
      paste0("Claim Type: ", info[[4]]), br(),
      paste0("Status: ", info[[5]]), br(),
      paste0("Institution: ", info[[6]]), br(),
      paste0("Details: ", info[[7]]), br(),
      paste0("Amount: ", info[[8]]), br(),
      hr(),br(),
      ...
    )
  )  
}

searchRequest <- function(current, title, flag){
  if(flag == TRUE) add <- "P"
  else add <- ""
  material_card(
    material_row(
      h5(title)
    ),
    material_row(
      material_column(
        width = 8,
        material_dropdown(
          input_id = paste0("req",add),
          label = "Choose request",
          color = "green",
          choices = requests(current)
        )
      ),
      material_column(
        width = 4,
        actionButton(paste0("det",add), "Detail", icon("folder-open"), 
                     style="color: #fff; background-color: #FFCC00")
      )
    )
  )
}



qa <- function(...){
  div(material_row(
    material_column(
      width = 12,
      material_card(
        title = "How to approve a request?",
        tags$br(),
        shiny::tags$h6("Click on green check button.")
      )
    )
  ))
}

g_actionLink <- function(...){
  div(actionLink(...), class="a1")
}

# validCheck <- function(i){
#   div(material_switch(
#     input_id = paste0(i,"a"),
#     label = "I confirm this request being",
#     off_label = "Invalid",
#     on_label = "Valid",
#     initial_value = TRUE,
#     color = "green"
#   ), style="color: green")
# }

w_paste0 <- function(text,...){
  div(paste0("text"), style="color: red", class="shiny-text-output shiny-bound-output", ...)
}