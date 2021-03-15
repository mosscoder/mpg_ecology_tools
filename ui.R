ui <-  fillPage(
  leafletOutput("myMap", height = '100%'),
  uiOutput("modal_1", width = '100%', height = '100%'),
  uiOutput("modal_2", width = '100%', height = '100%'),
  absolutePanel(img(src='https://www.mpgranch.com/sites/all/themes/custom/mpgranch_theme/images/icons/png/mpg_logo_white.png', height = '80'),
                bottom = '10px', left = '10px'),
  absolutePanel(switchInput(inputId = 'sim_mode', 'Similarity mode', value = FALSE, size = 'mini', onStatus = "success", 
                            offStatus = "danger"),
                top = 10, left = 50),
  setBackgroundColor("ghostwhite")
)