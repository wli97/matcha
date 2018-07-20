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
  if(request[[4]] == 1) request[[4]] <- "Waiting for Police validation..."
  else if(request[[4]] == 2) request[[4]] <- "Waiting for Repair Shop validation..."
  else if(request[[4]] == 3) request[[4]] <- "Waiting for Police & Repair Shop validation..."
  else if(request[[4]] == 4) request[[4]] <- "Police validation completed. Now waiting for Repair shop..."
  else if(request[[4]] == 5) request[[4]] <- "Repair shop validation completed. Now waiting for Police..."
  else if(request[[4]] == 6) request[[4]] <- "Validations completed. Now waiting for payment..."
  else if(request[[4]] == 7) request[[4]] <- "Police rejected your request."
  else if(request[[4]] == 8) request[[4]] <- "Repair shop rejected your request."
  else if(request[[4]] == 9) request[[4]] <- "Your institution rejected your request."
  else if(request[[4]] == 10) request[[4]] <- "Payment sent from the institution."
  request[[5]] <- "TDI"
  request[[8]] <- index
  return(request)
}

request <- function(id,title,info, ... ){
  div(material_row(
    material_column(
      width = 12,
      material_card(
        h5(title),
        hr(),
        material_modal(
          modal_id = id,
          button_text = "Detail",
          button_icon = "folder_special",
          title = "Request Details",
          hr(),
          button_depth = 2,
          button_color = "light-green",
          display_button = TRUE,
          paste0("Time requested: ", info[[1]]), br(),
          paste0("Police: ", info[[2]]), br(),
          paste0("Repair Shop: ", info[[3]]), br(),
          paste0("Status: ", info[[4]]), br(),
          paste0("Institution: ", info[[5]]), br(),
          paste0("Details: ", info[[6]]), br(),
          paste0("Amount Paid: ", info[[7]]), br(),
          ...
        )
      )
    )
  )
)}

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

# accept_material_modal <- function(id,...){
#   div(material_modal(
#     input_id = id,
#     icon = "check",
#     label = "",
#     depth = 3,
#     color = "amber"
#   ), ...)
# }

g_actionLink <- function(...){
  div(actionLink(...), style="color: green", class="a")
}

validCheck <- function(i){
  div(material_switch(
    input_id = paste0(i,"a"),
    label = "I confirm this request being",
    off_label = "Invalid",
    on_label = "Valid",
    initial_value = TRUE,
    color = "green"
  ), style="color: green")
}

w_paste0 <- function(text,...){
  div(paste0("text"), style="color: red", class="shiny-text-output shiny-bound-output", ...)
}