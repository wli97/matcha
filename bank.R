past <- vector("list", 1)
current <- vector("list", 1)
# update process can be improved with index checker, no need to reload past data

# ERROR: NOT APPEARING ARRAY. ALSO FORMAT ISSUE WITH PAYCLAIM
update <- function(){
  i<-0L
  j<-0L
  while(TRUE){
    valid <- getValid(USER$Address,i)
    if(length(valid) <= 1) break
    request <- getRequest(valid[[1]], valid[[2]])
    # if no timestamp, it is empty
    if(request[1] < 1) break
    if(request[4] != 6){
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
      material_card(
        material_row(
          material_column(
            width = 6,
            h5("Current Claims")
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
          request(paste0("cReq",i), paste0("Request #",i, " on ", current[[i]][[1]]),current[[i]],
                  validCheck(i),
                  material_text_box(
                    input_id = paste0(i, "b"),
                    label = "Optional: append any comment to this request.",
                    color = "green"
                  ),
                  material_number_box(
                    input_id = paste0(i, "d"),
                    label = "Amount to pay to client",
                    initial_value = 0,
                    max_value = 30000000,
                    min_value = 0,
                    color = "green"
                  ),
                  g_actionLink(
                    paste0(i,"c"),
                    label = "Submit",
                    color = "green"
                  ),
                  uiOutput(paste0("submitStatus",i)) )
        })
      }
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
      ),
      if(is.null(past[[1]])){
        material_row(
          material_column(
            width = 6,
            material_card(
              h5("No claim in records, fortunately!")
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
      ),
      qa()
    )
  )
})

lapply(1:length(current), function(i){
  observeEvent(input[[paste0(i,"c")]], {
    resp <- payClaim(current[[i]][[8]], input[[paste0(i,"a")]], paste0("BK ",": ",Sys.time(), input[[paste0(i,"b")]]), input[[paste0(i,"d")]])
    print(resp)
    if(resp == 0){
      output[[paste0("submitStatus",i)]] <- renderUI({
        div(h6("Validation failed, please try again later."), style="color:red")
      })
    }
    else{
      output[[paste0("submitStatus",i)]] <- renderUI({
        div(h6("Success."), style="color:green")
      })
    }
    
  })
})