library(reticulate)
library(shiny)
setwd("C:/Users/Johnny/Documents/UNH Notes and Documents 2018/world bank")
source_python("Ecolex_To_Dataframe_PK.py", convert = TRUE, envir = globalenv())
countries <- list('Aruba', 'Afghanistan','Albania','Algeria','American Samoa','Andorra','Angola','Anguilla','Antarctica','Antigua and Barbuda','Argentina','Armenia','Aruba','Australia','Austria','Azerbaijan','Bahamas','Bahrain','Bangladesh','Barbados','Belarus','Belgium','Belize','Benin','Bermuda','Bhutan','Bolivia','Bosnia and Herzegovina','Botswana','Bouvet Island','Brazil','British Indian Ocean Territory','Brunei Darussalam','Bulgaria','Burkina Faso','Burundi','Cambodia','Cameroon','Canada','Cape Verde','Cayman Islands','Central African Republic','Chad','Chile','China','Christmas Island','Cocos (Keeling) Islands','Colombia','Comoros','Congo','Congo,The Democratic Republic of The','Cook Islands','Costa Rica','Cote Divoire','Croatia','Cuba','Cyprus','Czech Republic','Denmark','Djibouti','Dominica','Dominican Republic','Ecuador','Egypt','El Salvador','Equatorial Guinea','Eritrea','Estonia','Ethiopia','Falkland Islands (Malvinas)','Faroe Islands','Fiji','Finland','France','French Guiana','French Polynesia','French Southern Territories','Gabon','Gambia','Georgia','Germany','Ghana','Gibraltar','Greece','Greenland','Grenada','Guadeloupe','Guam','Guatemala','Guinea','Guyana','Haiti','Heard Island and Mcdonald Islands','Honduras','Hong Kong','Hungary','Iceland','India','Indonesia','Iran','Islamic Republic of','Iraq','Ireland','Israel','Italy','Jamaica','Japan','Jordan','Kazakhstan','Kenya','Kiribati','Korea, Repulic of','Korea, Democratic Peoples Republic of','Kuwait','Kyrgyzstan','Lao Peoples Democratic Republic','Latvia','Lebanon','Lesotho','Liberia','Libyan Arab Jamahiriya','Liechtenstein','Lithuania','Luxembourg','Macao','Macedonia','The Former Yugoslav Republic of','Madagascar','Malawi','Malaysia','Maldives','Mali','Malta','Marshall Islands','Martinique','Mauritania','Mauritius','Mayotte','Mexico','Micronesia','Federated States of','Moldova','Republic of','Monaco','Mongolia','Montserrat','Morocco','Mozambique','Myanmar','Namibia','Nauru','Nepal','Netherlands','Netherlands Antilles','New Caledonia','New Zealand','Nicaragua','Niger','Nigeria','Niue','Norfolk Island','Northern Mariana Islands','Norway','Oman','Pakistan','Palau','Palestinian Territory','Occupied','Panama','Papua New Guinea','Paraguay','Peru','Philippines','Pitcairn','Poland','Portugal','Puerto Rico','Qatar','Reunion','Romania','Russian Federation','Rwanda','Saint Helena','Saint Kitts and Nevis','Saint Lucia','Saint Pierre and Miquelon','Saint Vincent and The Grenadines','Samoa','San Marino','Sao Tome and Principe','Saudi Arabia','Senegal','Serbia and Montenegro','Seychelles','Sierra Leone','Singapore','Slovakia','Slovenia','Solomon Islands','Somalia','South Africa','South Georgia and The South Sandwich Islands','Spain','Sri Lanka','Sudan','Suriname','Svalbard and Jan Mayen','Swaziland','Sweden','Switzerland','Syrian Arab Republic','Taiwan','Province of China','Tajikistan','Tanzania','United Republic of','Thailand','Togo','Tokelau','Tonga','Trinidad and Tobago','Tunisia','Turkey','Turkmenistan','Turks and Caicos Islands','Tuvalu','Uganda','Ukraine','United Arab Emirates','United Kingdom','United States','Uruguay','Uzbekistan','Vanuatu','Venezuela','Vietnam','Virgin Islands','British','Virgin Islands','U.S.','Wallis and Futuna','Western Sahara','Yemen','Zambia','Zimbabwe')
  
ui <- fluidPage(
  
    selectInput("text","Select Country", choices = countries),
    #textInput("text", "Enter Country", value = "Aruba"),
    submitButton("Run", icon("refresh")),
    br(),
    downloadButton('downloadData', 'Download Laws'),
    br(),
    mainPanel(dataTableOutput(outputId = "table"))
    
  )


server <- function(input, output, session) {
  
  mylist <- reactiveVal() # we will store the inputs in a reactive list
  
  observe({ # create the list
    mylist((
      text = input$text))
   })
  
  output$table <- renderDataTable(
    {
      create_law_df(mylist())
    })
  

  output$downloadData <- downloadHandler(
    
    # This function returns a string which tells the client
    # browser what name to use when saving the file.
    filename = function() {
      paste(mylist(), "csv", sep = ".")
    },
    
    # This function should write data to a file given to it by
    # the argument 'file'.
    content = function(file) {
      sep <- (",")
      
      # Write to a file specified by the 'file' argument
      write.table(create_law_df(mylist()), file, sep = sep,
                  row.names = FALSE)
  
      
    }
  )
  
}


shinyApp(ui, server)
