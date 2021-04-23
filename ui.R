ui <-  fillPage(
  leafletOutput("myMap", height = '100%'),
  uiOutput("modal_1", width = '100%', height = '100%'),
  uiOutput("modal_2", width = '100%', height = '100%'),
  absolutePanel(
    img(src = 'https://www.mpgranch.com/sites/all/themes/custom/mpgranch_theme/images/icons/png/mpg_logo_white.png', height = '80'),
    bottom = '10px',
    left = '10px'
  ), 
  absolutePanel(
    selectInput(
      width = '130px',
      label = NULL,
      inputId = 'pt_select',
      choices = point_choices
    ),
    textInput(label = NULL,
              placeholder = "Zoom to point...",
                 input = 'zoom_id',
                 width = '130px'),
    switchInput(
      inputId = 'sim_mode',
      'Similarity Mode',
      value = FALSE,
      size = 'mini',
      onStatus = "success",
      offStatus = "danger"
    ),  
    top = 10,
    left = 10,
  ),
  absolutePanel( switchInput(
    inputId = 'standing_pts',
    'Standing Points',
    value = FALSE,
    size = 'mini',
    onStatus = "success",
    offStatus = "danger"
  ),
                top = 10, left = 145),
  absolutePanel(downloadButton(outputId = 'points_kml', label = NULL),
                top = 10, left = 245)
)