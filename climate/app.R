#CLIMATE APP
library(shiny)
library(climate)
library(shinythemes)
library(dplyr)
library(plotly)
library(writexl)
library(rsconnect)
library(shinydashboard)

#rsconnect::deployApp('D:/shiny/climate')

ui <- fluidPage(theme = shinytheme("readable"),
      dashboardPage(skin = "black",
        dashboardHeader(title = tags$a(tags$img(src = "https://github.com/sardine1/shiny/blob/main/climate/%D0%9B%D0%9E%D0%93%D0%9E_1-1small.png?raw=true", 
                                                align = "centre", width = 110, height = 80)), 
              tags$li(class = "dropdown",
                      tags$style(".main-header {max-height: 80px}"),
                      tags$style(".main-header .logo {height: 80px;}"),
                      tags$style(".sidebar-toggle {height: 80px; padding-top: 27px !important;}"),
                      tags$style(".navbar {min-height:80px !important}"),
                      
              ) ),
        dashboardSidebar(sidebarMenu(
          menuItem("Меню"),
          menuItem("Информация", tabName = "introduction", icon = icon("th")),
          menuItem("Температура", tabName = "temperature", icon = icon("th")),
          menuItem("Другое", tabName = "widgets", icon = icon("th"))
        )),
        dashboardBody(
          
          tabItems(
            # Первая вкладка
            tabItem(tabName = "introduction",
                    fluidRow(
                      tabBox(
                        #title = "Первый блок",
                        id = "tabset1", height = "300px",
                        tabPanel("Общее", h5("Информация по вкладке Температура"), br(),
                                 "1. Необходимо выбрать станцию (с полным списком станций можно ознакомиться в Станции);", br(),
                                 "2. Необходимо задать начальную и конечную даты;", br(),
                                 "После изменения данных внизу обновится таблица с данными по температуре за выбранный промежуток.", br(),
                                 "Также будет построен график средней температуры за выбранный промежуток времени."),
                        tabPanel("Файл", h5("Информация по выгрузке файла"), br(),
                                 "Файл содержит:", br(),
                                 "1. TemperatureCAvg – средняя температура воздуха на высоте 2 метров над уровнем земли. Значение, указанное в градусах Цельсия;", br(),
                                 "2. TemperatureCMax – максимальная температура воздуха на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "3. TemperatureCMin – минимальная температура воздуха на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "4. TdAvgC – средняя температура точки росы на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "5. HrAvg – средняя относительная влажность. Значения, приведенные в %;", br(),
                                 "6. WindkmhDir – направление ветра;", br(),
                                 "7. WindkmhInt – скорость ветра в км/ч;", br(),
                                 "8. WindkmhGust – порыв ветра в км/ч;", br(),
                                 "9. PresslevHp – давление на уровне моря в ГПа;", br(),
                                 "10. Precmm – общее количество осадков в мм;", br(),
                                 "11. TotClOct – общая облачность в октантах;", br(),
                                 "12. lowClOct – облачность из-за низкоуровневых облаков в октантах;", br(),
                                 "13. SunD1h – продолжительность солнечного сияния в часах;", br(),
                                 "14. PreselevHp – атмосферное давление, измеренное на высоте станции в ГПа;", br(),
                                 "15. SnowDepcm – глубина снежного покрова в сантиметрах;", br()),
                        tabPanel("Станции", h5("Наименование станций в России"), br(), "Belogorka,
                          Nikolaevskoe, Volosovo, Lomonosov, St.petersburg (Voejkovo),
                          Dno, Ljuban, Novgorod, Petrokrepost, Kingisepp,
                          Staraja Russa, Pskov, Kirishi, Vyborg, Gdov,
                          Holm, Puskinskie Gory, Valaam, Novaja Ladoga,
                          Opochka, Krestcy, Velikie Luki, Sortavala,
                          Demjansk, Toropets, Olonec, Velizh,
                          Tihvin, Ostaskov, Suoyarvi, Lodejnoe Pole,
                          Borovici, Bologoe, Belyj, Smolensk,
                          Efimovskaja, Vysnij Volocek,Reboly, Vinnicy,
                          Petrozavodsk, Pochinok, Kondopoga, Padany,
                          Staritsa, Ohony, Roslavl, Vjaz'Ma,
                          Medvezegorsk, Babaevo, Maksatikha, Spas-Demensk,
                          Gagarin, Krasnaja Gora, Tver, Kalevala,
                          Segeza, Ustyuzhna, Zukovka, Vytegra,
                          Pudoz, Krasnyy Kholm, Brjansk, Klin,
                          Suhinici, Raznavolok, Trubcevsk, Novo-Jerusalim,
                          Dubna (Ctbt), Malojaroslavec, Naro-Fominsk, Port,
                          Kasin, Engozero, Belozersk, Kolezma,
                          Cerepovec, Moskva (Dolgoprudnyj), Kovda, Kreml,
                          Uglic, Kandalaksa, Orel, Mcensk,
                          Rybinsk, Umba, Tula, Poshehon'e, Kasira, Apatity,
                          Ponyri, Zizgin, Pavlovskij Posad, Kargopol, Chernyahovsk,
                          Monchegorsk, Onega, Kashkarantsy, Kursk, Uzlovaja, Rostov,
                          Padun, Konevo, Vologda, Efremov, Gotnja, Obojan,
                          Yaniskoski, Livny, Turcasovo, Unskij Majak,
                          Vozega, Lovozero, Nikel, Murmansk,
                          Konosha, Njandoma, Pavelec, Elec,
                          Rjazan, Bogoroditskoe-Fenino, Vladimir, Kostroma,
                          Krasnoscel'E, Vajda-Guba, Ivanovo, Gus'- Hrustal'Nyj,
                          Severodvinsk, Teriberka, Lipeck, Rjazsk,
                          Buj, Zimnegorskij Majak,Voronez, Mud'Jug,
                          Pjalica, Valujki, Arhangel'Sk, Micurinsk,
                          Vel'Sk, Liski, Elat'Ma, Emeck,
                          Kanevka, Vyksa, Holmogory, Tot'ma,
                          Sasovo, Anna, Tambov, Morsansk,
                          Jur'Evec, Senkursk, Kamennaja Step,
                          Dvinskij Bereznik, Nikolo-Poloma,
                          Kepino, Shangaly, Zerdevka, Volzskaja Gmo,
                          Zametcino, Bogucar, Temnikov, Kalac,
                          Kirsanov, Arzamas, Niznij Novgorod, Vologda,
                          Poshehon'e, Vozega, Kostroma, Rybinsk,
                          Buj, Rostov, Konosha, Cerepovec,
                          Ivanovo, Uglic, Belozersk, Njandoma,
                          Kargopol, Vladimir")
                      ),
                      tabBox(
                        #title = "Второй блок",
                        side = "right", height = "300px",
                        selected = "Tab3",
                        tabPanel("Tab1", "Tab content 1"),
                        tabPanel("Tab2", "Tab content 2"),
                        tabPanel("Tab3", "Note that when side=right, the tab order is reversed.")
                      )
                    ),
                    
            ),
            
            # Вторая вкладка
            tabItem(tabName = "temperature",
                    box(status = "primary",
                    width = "100%",
                    HTML("<h3>Изменяемые параметры</h3>"),
                    
                    selectInput("station", label = "Станция:", 
                                #станции
                                choices = list("Belogorka" = "26069", "Nikolaevskoe" = "26167", "Volosovo" = "26067", "Lomonosov" = "26060",
                                               "St.petersburg (Voejkovo)" = "26063", "Dno" = "26268",
                                               "Ljuban" = "26078", "Novgorod" = "26179", "Petrokrepost" = "26072", "Kingisepp" = "26059",
                                               "Staraja Russa" = "26275", "Pskov" = "26258", "Kirishi" = "26080", "Vyborg" = "22892",
                                               "Gdov" = "26157", "Holm" = "26378", "Puskinskie Gory" = "26359", "Valaam" = "22805",
                                               "Novaja Ladoga" = "22917", "Opochka" = "26456", "Krestcy" = "26285", "Velikie Luki" = "26477",
                                               "Sortavala" = "22802", "Demjansk" = "26381", "Toropets" = "26479", "Olonec" = "22912",
                                               "Velizh" = "26578", "Tihvin" = "26094", "Ostaskov" = "26389", "Suoyarvi" = "22717",
                                               "Lodejnoe Pole" = "22913", "Borovici" = "26291", "Bologoe" = "26298", "Belyj" = "26585",
                                               "Smolensk" = "26781", "Efimovskaja" = "26099", "Vysnij Volocek" = "26393", "Reboly" = "22602",
                                               "Vinnicy" = "22925", "Petrozavodsk" = "22820", "Pochinok" = "26784", "Kondopoga" = "22727",
                                               "Padany" = "22619", "Staritsa" = "26499", "Ohony" = "27108", "Roslavl" = "26882",
                                               "Vjaz'Ma" = "26695", "Medvezegorsk" = "22721", "Babaevo" = "27008", "Maksatikha" = "27208",
                                               "Spas-Demensk" = "26795", "Gagarin" = "27507", "Krasnaja Gora" = "26976", "Tver" = "27402",
                                               "Kalevala" = "22408", "Segeza" = "22621", "Ustyuzhna" = "27106", "Zukovka" = "26894",
                                               "Vytegra" = "22837", "Pudoz" = "22831", "Krasnyy Kholm" = "27215", "Brjansk" = "26898",
                                               "Klin" = "27417", "Suhinici" = "27707", "Raznavolok" = "22525", "Trubcevsk" = "26997",
                                               "Novo-Jerusalim" = "27511", "Dubna (Ctbt)" = "27415", "Malojaroslavec" = "27606", "Naro-Fominsk" = "27611",
                                               "Port" = "22520", "Kasin" = "27316", "Engozero" = "22413", "Belozersk" = "22939",
                                               "Kolezma" = "22529", "Cerepovec" = "27113", "Moskva (Dolgoprudnyj)" = "27612", "Kovda" = "22312",
                                               "Kreml" = "22429", "Uglic" = "27321", "Kandalaksa" = "22217", "Orel" = "27906",
                                               "Mcensk" = "27817", "Rybinsk" = "27225", "Umba" = "22324", "Tula" = "27719", "Poshehon'e" = "27223",
                                               "Kasira" = "27627", "Apatity" = "22213", "Ponyri" = "34003", "Zizgin" = "22438",
                                               "Pavlovskij Posad" = "27523", "Kargopol" = "22845", "Chernyahovsk" = "26711", "Monchegorsk" = "22212",
                                               "Onega" = "22641", "Kashkarantsy" = "22334", "Kursk" = "34009", "Uzlovaja" = "27821", "Rostov" = "27329",
                                               "Padun" = "22106", "Konevo" = "22749", "Vologda" = "27037", "Efremov" = "27921",
                                               "Gotnja" = "34202", "Obojan" = "34109", "Yaniskoski" = "22101", "Livny" = "34013",
                                               "Turcasovo" = "22648", "Unskij Majak" = "22541", "Vozega" = "22954", "Lovozero" = "22127",
                                               "Nikel" = "22004", "Murmansk" = "22113", "Konosha" = "22951", "Njandoma" = "22854",
                                               "Pavelec" = "27823", "Elec" = "27928", "Rjazan" = "27730", "Bogoroditskoe-Fenino" = "34110",
                                               "Vladimir" = "27532", "Kostroma" = "27333", "Krasnoscel'E" = "22235", "Vajda-Guba" = "22003",
                                               "Ivanovo" = "27347", "Gus'- Hrustal'Nyj" = "27539", "Severodvinsk" = "22546", "Teriberka" = "22028",
                                               "Lipeck" = "27930", "Rjazsk" = "27835", "Buj" = "27242", "Zimnegorskij Majak" = "22446",
                                               "Voronez" = "34123", "Mud'Jug" = "22551", "Pjalica" = "22349", "Valujki" = "34321", "Arhangel'Sk" = "22550",
                                               "Micurinsk" = "27935", "Vel'Sk" = "22867", "Liski" = "34231", "Elat'Ma" = "27648",
                                               "Emeck" = "22656", "Kanevka" = "22249", "Vyksa" = "27643", "Holmogory" = "22559", "Tot'ma" = "27051", "Sasovo" = "27745", "Anna" = "34238",
                                               "Tambov" = "27947", "Morsansk" = "27848", "Jur'Evec" = "27355",
                                               "Senkursk" = "22768", "Kamennaja Step" = "34139", "Dvinskij Bereznik" = "22762", "Nikolo-Poloma" = "27252",
                                               "Kepino" = "22456", "Shangaly" = "22869", "Zerdevka" = "34047", "Volzskaja Gmo" = "27453",
                                               "Zametcino" = "27857", "Bogucar" = "34336", "Temnikov" = "27752", "Kalac" = "34247",
                                               "Kirsanov" = "27957", "Arzamas" = "27653", "Niznij Novgorod" = "27459", "Vologda" = "27037",
                                               "Poshehon'e" = "27223", "Vozega" = "22954", "Kostroma" = "27333", "Rybinsk" = "27225",
                                               "Buj" = "27242", "Rostov" = "27329", "Konosha" = "22951", "Cerepovec" = "27113", "Ivanovo" = "27347", "Uglic" = "27321",
                                               "Belozersk" = "22939", "Njandoma" = "22854", "Kargopol" = "22845", "Vladimir" = "27532"), 
                                selected = "Novgorod"),
                    dateInput("date1", "Начальная дата:", value = "2022-02-21"),
                    dateInput("date2", "Конечная дата:", value = "2022-03-21"),
                    
                    actionButton("submitbutton", "Показать"),
                    br(),
                    
                    HTML("<h3>Скачать файл с данными</h3>"),
                    textInput("caption", "Наименование файла", value = "Climate_app_data_"),
                    downloadButton("download", "Скачать"),
                    
                    br(),
                    mainPanel(
                    tags$label(h3('График средней температуры по заданному интервалу времени')),
                    plotlyOutput("printplot"),
                    tags$hr(),
                    tableOutput("printtable")
                      
                    ))
            ),
            
            #Третья вкладка
            tabItem(tabName = "widgets",
                    h2("tab content")
            )
          )
        )
      )           
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # Plot1
  output$printplot <- renderPlotly({
    
    input$submitbutton
    
    daf <- data.frame(
      Name = c("station",
               "date1",
               "date2",
               "caption"),
      Value = as.character(c(input$station,
                             input$date1,
                             input$date2,
                             input$caption)),
      stringsAsFactors = FALSE)
    
    df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
    
    data1 <- data.frame(df[3], df[2])
    fig1 <- plot_ly(data1, x = ~ Date, y = ~ TemperatureCAvg) %>% 
      add_lines()
    fig1 
    
  })
  
  
  # Data Table
  output$printtable <- renderTable({  
    
    input$submitbutton
    
    df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
    
    df1 = df[2]
    
    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:5])
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:5])
    
  })
  
  output$download <- downloadHandler(
    
    filename = function() {
      paste(input$caption, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station), file)}
    
  )
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
