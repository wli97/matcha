c_material_parallax <-function(image_source, 
                               style = "height:300px", 
                               ...){
  
  div(material_parallax(
    image_source = image_source
  ),style= style, class="parallax-container", ...)
  
}

formatRequest <- function(request){
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
  return(request)
}

request <- function(id,title,info, ... ){
  div(material_row(
    material_column(
      width = 12,
      material_card(
        title = title,
        material_row(
        material_column(
          width = 6,
          tags$br(),
          material_modal(
            modal_id = id,
            button_text = "Detail",
            button_icon = "folder_special",
            title = "Request Details",
            button_depth = 2,
            button_color = "orange",
            display_button = TRUE,
            paste0("Time requested: ", info[[1]]), br(),
            paste0("Police: ", info[[2]]), br(),
            paste0("Repair Shop: ", info[[3]]), br(),
            paste0("Status: ", info[[4]]), br(),
            paste0("Institution: ", info[[5]]), br(),
            paste0("Details: ", info[[6]]), br(),
            paste0("Amount Paid: ", info[[7]])
          )
        )
      )
    )
  ),...
))}

# claimText <- renderUI({
#   paste0("Institution: ", info[[5]])
#   paste0("Police involvement: ", info[[3]])
#   paste0("Garage involvement: ", info[[2]])
#   paste0("Status: ", info[4])
#   paste0("Progress note: ", info[6])
#   paste0("Payment: ", info[7])
# })

claims <- function(id,title, ... ){
  div(material_row(
    material_column(
      width = 12,
      material_card(
        title = title,
        material_row(
          material_column(
            width = 6,
            tags$br(),
            material_modal(
              modal_id = id,
              button_text = "Detail",
              button_icon = "folder_special",
              title = "Incident details",
              button_depth = 2,
              button_color = "orange",
              display_button = TRUE,
              shiny::tags$p("Accident 440O, car crash.")
            )
          ),
          material_column(
            width = 3,
            deny_material_button(paste(id,"a"))
          ),
          material_column(
            width = 3,
            accept_material_button(paste(id,'b'))
          )
        )
      )
    )
  ),...
  )}

accept_material_button <- function(id,...){
  div(material_button(
    input_id = id,
    icon = "check",
    label = "",
    depth = 3,
    color = "green"
  ), ...)
}

deny_material_button <- function(id,...){
  div(material_button(
    input_id = id,
    label = "",
    icon = "clear",
    depth = 3,
    color = "red"
  ), ...)
}

g_actionLink <- function(...){
  div(actionLink(...), style="color: green", class="a")
}

w_paste0 <- function(text,...){
  div(paste0("text"), style="color: red", class="shiny-text-output shiny-bound-output", ...)
}