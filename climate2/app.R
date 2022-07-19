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
library(ggmap)
library(shinycssloaders)
library(rio)
library(echarts4r)

y <- import("https://raw.githubusercontent.com/sardine1/shiny/main/climate/stations.csv")

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
                                           menuItem("По дням", tabName = "temperature_daily"),
                                           menuItem("По месяцам", tabName = "temperature_monthly")),
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
                                                       "Ближайшее обновление запланировано на 29.06", br(),
                                                       "Если есть вопросы и предложения – пишите на почту dllab@sfu-kras.ru")
                                            ),
                                            tabBox(
                                              #title = "Второй блок",
                                              side = "right", height = "100%",
                                              selected = "Общее",
                                              tabPanel("Общее", h5("Информация по вкладке Температура"), br(),
                                                       "1. Необходимо выбрать, какие данные хотите получить: почасовые, подневные, помесячные;", br(),
                                                       "2. Необходимо выбрать станцию (с полным списком станций можно ознакомиться в Станции или получить список в зависимости от долготы во вкладке Станции);", br(),
                                                       "3. Необходимо задать начальную и конечную даты;", br(),
                                                       "После изменения данных внизу обновится таблица с данными по температуре за выбранный промежуток.", br(),
                                                       "Данные можно скачать в формате .csv", br(),
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
                                                       "15. SnowDepcm – глубина снежного покрова в сантиметрах;", br(),
                                                       h6("Файл с данными по месяцам содержит:"), br(),
                                                       "0. Station_ID - идентификатор станции", br(),
                                                       "1. Year - год", br(),
                                                       "2. Month - месяц", br(),
                                                       "3. MeanTemperature – средняя температура воздуха на высоте 2 метров над уровнем земли. Значение, указанное в градусах Цельсия;")
                                              #tabPanel("Станции", h5("Наименование станций в России"), br(), 
                                              #  "Ознакомиться со станциями России в зависимости от долготы можно на вкладке станции")
                                            )
                                          )
                                          
                                  ),
                                  
                                  # Первое вложение
                                  tabItem(tabName = "temperature_hourly",
                                          box(width = "100%",
                                              HTML("<h3>Изменяемые параметры</h3>"),
                                              sidebarPanel(width = "100%",
                                                           selectInput("region_seek_hourly", "Регионы", choices = unique(y$region)),
                                                           selectInput("station_seek_hourly", "Станции", choices = NULL),
                                              ),
                                              selectInput("station_hourly", label = "Станция:", 
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
                                              #h6("Формат даты : yyyy-mm-dd."), 
                                              h6("При вводе даты с клавиатуры разделитель может быть любой, например, пробел, по окончании необходимо нажать enter."),
                                              dateInput("date_hourly_start", "Начальная дата:", min = "2013-01-01", value = "2022-01-01", startview = 'year', format = "yyyy-mm-dd"),
                                              dateInput("date_hourly_end", "Конечная дата:", min = "2013-01-01", value = "2022-03-31", startview = 'year', format = "yyyy-mm-dd"),
                                              
                                              actionButton("submitbutton", "Показать"),
                                              br(),
                                              
                                              HTML("<h3>Скачать файл с данными</h3>"),
                                              textInput("caption_hourly", "Наименование файла", value = "Climate_data_hourly"),
                                              downloadButton("download", "Скачать"),
                                              
                                              br(),
                                              mainPanel(
                                                tags$label(h3('Данные')),
                                                tags$hr(),
                                                tableOutput("printtable") %>% withSpinner(color="#6fc50d")
                                                
                                              ))
                                  ),
                                  
                                  # Второе вложение
                                  tabItem(tabName = "temperature_daily",
                                          box(width = "100%",
                                              HTML("<h3>Изменяемые параметры</h3>"),
                                              sidebarPanel(width = "100%",
                                                           selectInput("region_seek_daily", "Регионы", choices = unique(y$region)),
                                                           selectInput("station_seek_daily", "Станции", choices = NULL),
                                              ),
                                              selectInput("station_daily", label = "Станция:", 
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
                                              #h6("Формат даты : yyyy-mm-dd."), 
                                              h6("При вводе даты с клавиатуры разделитель может быть любой, например, пробел, по окончании необходимо нажать enter."),
                                              dateInput("date_daily_start", "Начальная дата:", min = "2013-01-01", value = "2022-02-21", format = "yyyy-mm-dd"),
                                              dateInput("date_daily_end", "Конечная дата:", min = "2013-01-01", value = "2022-03-21", format = "yyyy-mm-dd"),
                                              
                                              HTML("<h3>Изменить параметр графика</h3>"),
                                              
                                              selectInput("param_daily", label = "Абсцисса",
                                                          choices = list("Average air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCAvg", 
                                                                         "Maximum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMax",
                                                                         "Minimum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMin", 
                                                                         "Average dew point temperature at 2 metres above ground level. Values given in Celsius degrees" = "TdAvgC"),
                                                          selected = "Average air temperature at 2 metres above ground level. Values given in Celsius degrees"),
                                              
                                              actionButton("submitbutton", "Показать"),
                                              br(),
                                              
                                              HTML("<h3>Скачать файл с данными</h3>"),
                                              textInput("caption_daily", "Наименование файла", value = "Climate_data_daily"),
                                              downloadButton("download_daily", "Скачать"),
                                              
                                              br(),
                                              mainPanel(
                                                tags$label(h3('График средней температуры по заданному интервалу времени')),
                                                plotlyOutput("printplot_daily") %>% withSpinner(color="#6fc50d"),
                                                tags$hr(),
                                                tableOutput("printtable_daily") %>% withSpinner(color="#6fc50d")
                                                
                                              ))
                                  ),
                                  
                                  #Третье вложение
                                  tabItem(tabName = "temperature_monthly",
                                          box(width = "100%",
                                              HTML("<h3>Изменяемые параметры</h3>"),
                                              selectInput("station_monthly", label = "Станция:", 
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
                                              #textInput("year", label = h5("Год"), value = "2022"),
                                              h6("Формат даты : yyyy-mm-dd."), 
                                              h6("При вводе даты с клавиатуры разделитель может быть любой, по окончании необходимо нажать enter."),
                                              dateInput("date_monthly_start", "Начальная дата:", min = "2013-01-01", value = "2021-02-01", format = "yyyy-mm-dd"),
                                              h6("Начальная дата – первое число месяца"),
                                              dateInput("date_monthly_end", "Конечная дата:", min = "2013-01-01", value = "2021-12-31", format = "yyyy-mm-dd"),
                                              h6("Конечная дата – последний день месяца"),
                                              #selectInput("month_from", label = "С",
                                              #            choices = list("January" = "01", "February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12")),
                                              #selectInput("month_to", label = "По (включая)",
                                              #            choices = list("February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12"))
                                              actionButton("submitbutton", "Показать"),
                                              br(),
                                              
                                              HTML("<h3>Скачать файл с данными</h3>"),
                                              textInput("caption_monthly", "Наименование файла", value = "Climate_data_montly"),
                                              downloadButton("download_montly", "Скачать"),
                                              
                                              br(),
                                              mainPanel(
                                                tags$label(h3('График средней температуры по заданному интервалу времени')),
                                                plotlyOutput("printplot_monthly") %>% withSpinner(color="#6fc50d"),
                                                tags$hr(),
                                                tableOutput("printtable_monthly") %>% withSpinner(color="#6fc50d")
                                              ))
                                  ),
                                  
                                  #Четвертая вкладка
                                  tabItem(tabName = "station_tab",
                                          h2("Станции России"),
                                          box(width = "100%",
                                              h3("Долгота"),
                                              textInput("from", label = h5("От"), value = "30"),
                                              textInput("to", label = h5("До"), value = "85"),
                                              actionButton("submitbutton", "Показать"),
                                              br(),
                                              mainPanel(
                                                tags$label(h3('Данные')),
                                                plotlyOutput("printplot_map") %>% withSpinner(color="#6fc50d"),
                                                tags$hr(),
                                                tableOutput("printtable_station") %>% withSpinner(color="#6fc50d")
                                              ))
                                  )
                                  
                                )
                              )
                )           
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  f_region_seek <- reactive({
    req(input$region_seek_hourly)
    filter(y, region == input$region_seek_hourly)
  })
  f_station_seek <- reactive({
    req(input$station_seek_hourly)
    filter(f_region_seek(), station == input$station_seek_hourly)
  })
  
  observeEvent(f_region_seek(), {
    updateSelectInput(session, "station_seek_hourly", choices = unique(f_region_seek()$station), selected = character())
  })
  
  f_region_seek_daily <- reactive({
    req(input$region_seek_daily)
    filter(y, region == input$region_seek_daily)
  })
  f_station_seek_daily <- reactive({
    req(input$station_seek_daily)
    filter(f_region_seek_daily(), station == input$station_seek_daily)
  })
  
  observeEvent(f_region_seek_daily(), {
    updateSelectInput(session, "station_seek_daily", choices = unique(f_region_seek_daily()$station), selected = character())
  })
  
  data <- eventReactive(input$submitbutton,{
    rnorm(1:100000)
  })
  
  # Plot Daily
  output$printplot_daily <- renderPlotly({
    
    input$submitbutton
    
    daf_daily <- data.frame(
      Name = c("station_seek_daily",
               "date_daily_start",
               "date_daily_end",
               "param_daily",
               "caption_daily"),
      Value = as.character(c(input$station_seek_daily,
                             input$date_daily_start,
                             input$date_daily_end,
                             input$param_daily,
                             input$caption_daily)),
      stringsAsFactors = FALSE)
    
    num_station_daily <- subset(y, station == input$station_seek_daily)
    
    time_start = input$date_daily_start
    time_end = input$date_daily_end
    
    time1_end = num_station_daily[4]
    
    if (time_start < time1_end){
      time_start = time1_end
      if(time_end< time1_end){
        time_end = "2015-12-31"
      }
    }
    
    df = meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(num_station_daily[3]))
    data1 = data.frame(df[names(df) == input$param_daily], df[2])
    if (input$param_daily == "TemperatureCAvg") {
      fig1 = plot_ly(data1, x = ~ Date, y = ~ TemperatureCAvg) %>% 
        add_lines()
      
    } else if (input$param_daily == "TemperatureCMax") {
      fig1 = plot_ly(data1, x = ~ Date, y = ~ TemperatureCMax) %>% 
        add_lines()
      fig1
    } else if (input$param_daily == "TemperatureCMin") {
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
  
  # Data Table Hourly
  output$printtable <- renderTable({  
    
    input$submitbutton
    
    daf_hourly <- data.frame(
      Name = c("station_seek_hourly",
               "date_hourly_start",
               "date_hourly_end",
               "caption_hourly"),
      Value = as.character(c(input$station_seek_hourly,
                             input$date_hourly_start,
                             input$date_hourly_end,
                             input$caption_hourly)),
      stringsAsFactors = FALSE)
    
    num_station_hourly <- subset(y, station == input$station_seek_hourly)
    
    df = meteo_ogimet(interval = "hourly", date = c(input$date_hourly_start, input$date_hourly_end), station = as.numeric(num_station_hourly[3]))
    
    df1 = df[2]
    
    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
  })
  
  # Download data hourly
  output$download <- downloadHandler(
    
    filename = function() {
      paste(input$caption_hourly, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(meteo_ogimet(interval = "hourly", date = c(input$date_hourly_start, input$date_hourly_end), station = as.numeric(subset(y, station == input$station_seek_hourly)[3])), file)}
    
  )
  
  # Data Table Daily
  output$printtable_daily <- renderTable({  
    
    input$submitbutton
    
    num_station_daily <- subset(y, station == input$station_seek_daily)
    
    df = meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(num_station_daily[3]))
    
    df1 = df[2]
    
    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
    
  })
  
  # Download data daily
  output$download_daily <- downloadHandler(
    
    filename = function() {
      paste(input$caption, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(subset(y, station == input$station_seek_daily)[3])), file)}
    
  )
  
  # Plot monthly
  output$printplot_monthly <- renderPlotly({
    input$submitbutton
    
    daf_daily <- data.frame(
      Name = c("station_monthly",
               "date_monthly_start",
               "date_monthly_end",
               "caption_monthly"),
      Value = as.character(c(input$station_monthly,
                             input$date_monthly_start,
                             input$date_monthly_end,
                             input$caption_monthly)),
      stringsAsFactors = FALSE)
    
    df = meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = input$station_monthly)
    
    hobofull <- df %>%
      tidyr::separate('Date',
                      into = c('year', 'month', 'day'),
                      sep= '-',
                      remove = FALSE)
    hobofullmean <- hobofull %>%
      group_by(year, month)%>%
      summarise(meantemp = mean(TemperatureCAvg))
    
    hobofullmean$x <- paste(hobofullmean$year, "-", hobofullmean$month)
    
    fig1 = plot_ly(hobofullmean, x = ~ x, y = ~ meantemp) %>% 
      add_lines()
    fig1
    
  })
  
  # Data Table Monthly
  output$printtable_monthly <- renderTable({
    
    input$submitbutton
    
    df_monthly = meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = input$station_monthly)
    
    hobofull <- df_monthly %>%
      tidyr::separate('Date',
                      into = c('year', 'month', 'day'),
                      sep= '-',
                      remove = FALSE)
    
    hobofullmean <- hobofull %>%
      group_by(year, month)%>%
      summarise(meantemp = mean(TemperatureCAvg))
    
    hobofullmean
    
  })
  
  # Download data montly
  output$download_montly <- downloadHandler(
    
    filename = function() {
      paste(input$caption_monthly, Sys.Date(), ".csv", sep="")
    },
    content = function(file) {write.csv(
      hobofullmean <- meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = input$station_monthly) %>%
        tidyr::separate('Date',
                        into = c('year', 'month', 'day'),
                        sep= '-',
                        remove = FALSE) %>%
        group_by(year, month)%>%
        summarise(meantemp = mean(TemperatureCAvg))
      , file)}
  )
  
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
  
  # Plot station
  output$printplot_map <- renderPlotly({
    
    my_df = nearest_stations_ogimet(country = "Russia",
                                    date = Sys.Date(),
                                    point = c(input$from, input$to),
                                    no_of_stations = 300)
    
    qmplot(lon, lat, data = my_df, colour = I('red'), size = I(2), darken = .3)
    
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)