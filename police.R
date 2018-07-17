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
      claims(0001,"Claim #0001-----2G9FX19-----2018-06-30")
      ,claims(0001,"Claim #0002-----2G9FX19-----2018-06-30")
      ,claims(0001,"Claim #0003-----2G9FX19-----2018-06-30")
      ,claims(0001,"Claim #0004-----2G9FX19-----2018-06-30")
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
            title = "How to approve a request?",
            tags$br(),
            shiny::tags$h6("Click on green check button.")
          )
        )
      )
    )
  )
})

output$currentClaims <- renderUI({
  div(for (x in {1;10}){
    claims(0001,"Claim #0001-----2G9FX19-----2018-06-30")
  })
})
