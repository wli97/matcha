output$page <- renderUI({
  div(
    material_side_nav(
      fixed = TRUE,
      image_source = "img/tdb.PNG",
      material_side_nav_tabs(
        side_nav_tabs = c(
          "Darknet" = "current"
          ,"Illuminati" = "history"
          ,"Horror" = "qa"
        ),
        icons = c("monetization_on"
                  ,"insert_chart"
                  ,"question_answer"
        )
      )
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "current",
      c_material_parallax('./img/td_bank.jpg', style="height:600px")
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "qa",
      c_material_parallax('./img/download.jpg', style="height:1000px")
      
    ),
    
    material_side_nav_tab_content(
      side_nav_tab_id = "Illuminati",
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