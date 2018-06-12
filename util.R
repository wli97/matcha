c_material_parallax <-function(image_source, 
                               style = "height:300px", 
                               ...){
  
  div(material_parallax(
    image_source = image_source
  ),style= style, class="parallax-container", ...)
  
}
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