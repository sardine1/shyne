#CLIMATE APP
library(shiny)
library(climate)
library(shinythemes)
library(dplyr)
library(plotly)
library(writexl)
library(rsconnect)
library(shinydashboard)
library(leaflet)

#rsconnect::deployApp('D:/shiny/climate')

ui <- fluidPage(theme = shinytheme("readable"),
      tags$head(HTML("<title>CLIMATE APP</title>")),
      dashboardPage(skin = "black",
        dashboardHeader(title = tags$a(tags$img(src = "https://raw.githubusercontent.com/sardine1/shiny/7c6b85fb1ace0fde505e013ef8d8b5daa664bd0e/climate/Cleo.svg", 
                                                align = "centre", width = "100%", height = "90%"))),
        dashboardSidebar(
          disable = FALSE, 
          width = NULL,
          collapsed = TRUE,
          sidebarMenu(
          menuItem("Меню"),
          menuItem("Информация", tabName = "introduction", icon = icon("book")),
          menuItem("Температура", icon = icon("thermometer"),
          menuItem("По часам", tabName = "temperature_hourly"),
          menuItem("По дням", tabName = "temperature_daily")),
          #menuItem("Темп месяц", tabName = "monthly", icon = icon("thermometer")),
          menuItem("Станции", tabName = "station_tab", icon = icon("list-alt"))
          
        ),
        tags$head(tags$style(HTML('.logo {
                              background-color: #FFFFFF !important;
                              }
                              .navbar {
                              background-color: #FFFFFF !important;
                              }')))),
        dashboardBody(
          tabItems(
            # Первая вкладка
            tabItem(tabName = "introduction",
                    fluidRow(
                      tabBox(
                        #title = "Первый блок",
                        id = "tabset1", height = "100%",
                        tabPanel("Инструкция", h5("Добро пожаловать!"), br(),
                                 "Здесь Вы можете ознакомиться с данными с Российских метеорологических станций. Данные доступны с 2000 года.", br(),
                                 br(),
                                 "Лаборатория экономики климатических изменений и экологического развития"),
                        tabPanel("Планы", h5("Планы по развитию"), br(), 
                                 "Обновление данного ресурса будет производиться постепенно.", br(),
                                 "Каждую неделю будет выпускаться новое обновление.", br(), br(),
                                 icon("calendar"),
                                 "Ближайшее обновление запланировано на 14.06", br(),
                                 "Если есть вопросы и предложения – пишите на почту dllab@sfu-kras.ru")
                      ),
                      tabBox(
                        #title = "Второй блок",
                        side = "right", height = "100%",
                        selected = "Общее",
                        tabPanel("Общее", h5("Информация по вкладке Температура"), br(),
                                 "1. Необходимо выбрать, какие данные хотите получить: почасовые или подневные;", br(),
                                 "2. Необходимо выбрать станцию (с полным списком станций можно ознакомиться в Станции или получить список в зависимости от долготы во вкладке Станции);", br(),
                                 "3. Необходимо задать начальную и конечную даты;", br(),
                                 "После изменения данных внизу обновится таблица с данными по температуре за выбранный промежуток.", br(),
                                 "Также будет построен график средней температуры за выбранный промежуток времени.", br(),
                                 br(), h5("Информация по вкладке Станции"), br(),
                                 "Можно выгрузить данные в зависимости от долготы со станциями России. Россия расположена между меридианами 19º восточной долготы (Западная точка — погранзастава Нормельн, Балтийская коса, Калининградская область) и 169º западной долготы (Восточная точка — остров Ратманова, Чукотский автономный округ)."),
                        tabPanel("Файл", h5("Информация по выгрузке файла"), br(),
                                 h6("Файл с почасовыми данными содержит:"), br(),
                                 "0. Station_ID - идентификатор станции", br(),
                                 "1. TC - температура воздуха на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "2. TdC - температура точки росы на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "3. TmaxC - максимальная температура воздуха на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "4. TminC - минимальная температура воздуха на высоте 2 метров над уровнем земли. Значения указаны в градусах Цельсия;", br(),
                                 "5. ddd - направление ветра;", br(),
                                 "6. ffkmh - скорость ветра в км/ч;", br(),
                                 "7. Gustkmh - порыв ветра в км/ч;", br(),
                                 "8. P0hpa - давление воздуха на высоте станции в ГПа;", br(),
                                 "9. PseahPa - давление на уровне моря в ГПа;", br(),
                                 "10. PTnd - тенденция давления в ГПа;", br(),
                                 "11. Nt - общий облачный покров;", br(),
                                 "12. Nh - облачный покров по фракции облаков высокого уровня;", br(),
                                 "13. HKm - высота основания облака;", br(),
                                 "14. InsoD1 - инсоляция в часах;", br(),
                                 "15. Viskm - видимость в километрах;", br(),
                                 "16. Snowcm - глубина снежного покрова в сантиметрах;", br(),
                                 "17. pr6 - общее количество осадков за 6 часов;", br(),
                                 "18. pr12 - общее количество осадков за 12 часов;", br(),
                                 "19. pr24 - общее количество осадков за 24 часа;", br(), br(),
                                  h6("Файл с данными по дням содержит:"), br(),
                                  "0. Station_ID - идентификатор станции", br(),
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
                                  "15. SnowDepcm – глубина снежного покрова в сантиметрах;", br())
                        #tabPanel("Станции", h5("Наименование станций в России"), br(), 
                        #  "Ознакомиться со станциями России в зависимости от долготы можно на вкладке станции")
                      )
                    )
                    
            ),
            
            # Вторая вкладка
            tabItem(tabName = "temperature_hourly",
                    box(width = "100%",
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
                    tags$label(h3('Данные')),
                    tags$hr(),
                    tableOutput("printtable")
                      
                    ))
            ),
            
            # Вторая вкладка
            tabItem(tabName = "temperature_daily",
                    box(width = "100%",
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
                        
                        HTML("<h3>Изменить параметр графика</h3>"),
                        
                        selectInput("param", label = "Абсцисса",
                                    choices = list("Average air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCAvg", 
                                                   "Maximum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMax",
                                                   "Minimum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMin", 
                                                   "Average dew point temperature at 2 metres above ground level. Values given in Celsius degrees" = "TdAvgC"),
                                    selected = "Average air temperature at 2 metres above ground level. Values given in Celsius degrees"),
                        
                        actionButton("submitbutton", "Показать"),
                        br(),
                        
                        HTML("<h3>Скачать файл с данными</h3>"),
                        textInput("caption", "Наименование файла", value = "Climate_app_data_"),
                        downloadButton("download_daily", "Скачать"),
                        
                        br(),
                        mainPanel(
                          tags$label(h3('График средней температуры по заданному интервалу времени')),
                          plotlyOutput("printplot_daily"),
                          tags$hr(),
                          tableOutput("printtable_daily")
                          
                        ))
            ),
            
            #Третья вкладка
            tabItem(tabName = "monthly",
                    box(
                      h2("Данные"),
                      textInput("year", label = h5("Год"), value = "2022"),
                      selectInput("month_from", label = "С",
                                  choices = list("January" = "01", "February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12")),
                      selectInput("month_to", label = "По (включая)",
                                  choices = list("February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12"))
                    )
            ),
            
            #Четвертая вкладка
            tabItem(tabName = "station_tab",
                    h2("Станции России"),
                    box(width = "100%",
                      h3("Долгота"),
                      textInput("from", label = h5("От"), value = "30"),
                      textInput("to", label = h5("До"), value = "85"),
                      
                      br(),
                      mainPanel(
                        tags$label(h3('Данные')),
                        tableOutput("printtable_station")
                        #tags$hr(),
                        #tableOutput("printtable")
                    ))
            )
            
          )
        )
      )           
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # Plot1
  output$printplot_daily <- renderPlotly({
    
    input$submitbutton
    
    daf <- data.frame(
      Name = c("station",
               "date1",
               "date2",
               "param",
               "caption"),
      Value = as.character(c(input$station,
                             input$date1,
                             input$date2,
                             input$param,
                             input$caption)),
      stringsAsFactors = FALSE)
    
    
      df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
      data1 = data.frame(df[names(df) == input$param], df[2])
      if (input$param == "TemperatureCAvg") {
        fig1 = plot_ly(data1, x = ~ Date, y = ~ TemperatureCAvg) %>% 
          add_lines()
        
      } else if (input$param == "TemperatureCMax") {
        fig1 = plot_ly(data1, x = ~ Date, y = ~ TemperatureCMax) %>% 
          add_lines()
        fig1
      } else if (input$param == "TemperatureCMin") {
        fig1 = plot_ly(data1, x = ~ Date, y = ~ TemperatureCMin) %>% 
          add_lines()
        fig1
      } else {
        fig1 = plot_ly(data1, x = ~ Date, y = ~ TdAvgC) %>% 
          add_lines()
        fig1
      }
      fig1
    
  })
  
  
  # Data Table Station
  output$printtable_station <- renderTable({
    input$submitbutton
    
    daf_station <- data.frame(
      Name = c("from",
               "to"),
      Value = as.character(c(input$from,
                             input$to)),
      stringsAsFactors = FALSE)
    
    
      nearest_stations_ogimet(country = "Russia",
                               date = Sys.Date(),
                               point = c(input$from, input$to),
                               no_of_stations = 300)
    
  })
  
  
  # Data Table 1
  output$printtable <- renderTable({  
    
    input$submitbutton
    
    df = meteo_ogimet(interval = "hourly", date = c(input$date1, input$date2), station = input$station)
    
    df1 = df[2]
    
    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
  })
  
  output$download <- downloadHandler(
    
    filename = function() {
      paste(input$caption, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(meteo_ogimet(interval = "hourly", date = c(input$date1, input$date2), station = input$station), file)}
    
  )
  
  # Data Table2
  output$printtable_daily <- renderTable({  
    
    input$submitbutton
    
    df = meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station)
    
    df1 = df[2]
    
    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
  })
  
  output$download_daily <- downloadHandler(
    
    filename = function() {
      paste(input$caption, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(meteo_ogimet(interval = "daily", date = c(input$date1, input$date2), station = input$station), file)}
    
  )
  
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
