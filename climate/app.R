# CLIMATE APP
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
library(shinymanager)

y <- import("https://raw.githubusercontent.com/sardine1/shiny/main/climate/stations.csv")

# rsconnect::deployApp('D:/shiny/climate')

credentials <- data.frame(
  user = c("1", "user"),
  password = c("1", "1"),
  admin = c(TRUE, FALSE)
)

palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))

page <- fluidPage(
  theme = shinytheme("readable"),
  tags$head(HTML("<title>CLIMATE APP</title>")),
  dashboardPage(
    skin = "black",
    dashboardHeader(title = tags$a(tags$img(
      src = "https://raw.githubusercontent.com/sardine1/shiny/7c6b85fb1ace0fde505e013ef8d8b5daa664bd0e/climate/Cleo.svg",
      align = "centre", width = "47%", height = "50%"
    ))),
    dashboardSidebar(
      disable = FALSE,
      width = NULL,
      collapsed = TRUE,
      sidebarMenu(
        menuItem("Информация", tabName = "introduction", icon = icon("book")),
        menuItem("Температура",
          icon = icon("thermometer"),
          menuItem("По часам", tabName = "temperature_hourly"),
          menuItem("По дням", tabName = "temperature_daily"),
          menuItem("По месяцам", tabName = "temperature_monthly"),
          menuItem("По годам", tabName = "temperature_yearly")
        ),
        # menuItem("Темп месяц", tabName = "monthly", icon = icon("thermometer")),
        menuItem("Станции", tabName = "station_tab", icon = icon("list-alt"))
      ),
      tags$head(tags$style(HTML(".logo {
                              background-color: #FFFFFF !important;
                              height: 100% !important;
                              }
                              .navbar {
                              background-color: #FFFFFF !important;
                              }")))
    ),
    dashboardBody(
      tabItems(
        # Первая вкладка
        tabItem(
          tabName = "introduction",
          fluidRow(
            tabBox(
              # title = "Первый блок",
              id = "tabset1", height = "100%",
              tabPanel(
                "Инструкция", h5("Добро пожаловать!"), br(),
                "Здесь Вы можете ознакомиться с данными с Российских метеорологических станций. Данные по некоторым станциям доступны с 2000 года.", br(),
                br(),
                "Лаборатория экономики климатических изменений и экологического развития"
              ),
              tabPanel(
                "Планы", h5("Планы по развитию"), br(),
                "Обновление данного ресурса будет производиться постепенно.", br(),
                "Каждую неделю будет выпускаться новое обновление.", br(), br(),
                "Если есть вопросы и предложения – пишите на почту dllab@sfu-kras.ru"
              )
            ),
            tabBox(
              # title = "Второй блок",
              side = "right", height = "100%",
              selected = "Общее",
              tabPanel(
                "Общее", h5("Информация по вкладке Температура"), br(),
                "1. Необходимо выбрать, какие данные хотите получить: почасовые, подневные, помесячные, годовые;", br(),
                "2. Необходимо выбрать регион, а затем станцию (с полным списком станций можно ознакомиться в Станции или получить список в зависимости от долготы во вкладке Станции);", br(),
                "3. Необходимо задать начальную и конечную даты;", br(),
                "После изменения данных внизу обновится таблица с данными по температуре за выбранный промежуток.", br(),
                "Данные можно скачать в формате .csv", br(),
                br(), h5("Информация по вкладке Станции"), br(),
                "Можно выгрузить данные в зависимости от долготы со станциями России. Россия расположена между меридианами 19º восточной долготы (Западная точка — погранзастава Нормельн, Балтийская коса, Калининградская область) и 169º западной долготы (Восточная точка — остров Ратманова, Чукотский автономный округ)."
              ),
              tabPanel(
                "Файл", h5("Информация по выгрузке файла"), br(),
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
                "3. MeanTemperature – средняя температура воздуха на высоте 2 метров над уровнем земли. Значение, указанное в градусах Цельсия;"
              )
              # tabPanel("Станции", h5("Наименование станций в России"), br(),
              #  "Ознакомиться со станциями России в зависимости от долготы можно на вкладке станции")
            )
          )
        ),

        # Первое вложение
        tabItem(
          tabName = "temperature_hourly",
          box(
            width = "100%",
            HTML("<h3>Изменяемые параметры</h3>"),
            sidebarPanel(
              width = "100%",
              selectInput("region_seek_hourly", "Регионы", choices = unique(y$region)),
              selectInput("station_seek_hourly", "Станции", choices = NULL),
            ),
            # h6("Формат даты : yyyy-mm-dd."),
            h6("При вводе даты с клавиатуры разделитель может быть любой, например, пробел, по окончании необходимо нажать enter."),
            dateInput("date_hourly_start", "Начальная дата:", min = "2013-01-01", value = "2022-01-01", startview = "year", format = "yyyy-mm-dd"),
            dateInput("date_hourly_end", "Конечная дата:", min = "2013-01-01", value = "2022-03-31", startview = "year", format = "yyyy-mm-dd"),
            actionButton("submitbutton", "Показать"),
            br(),
            HTML("<h3>Скачать файл с данными</h3>"),
            textInput("caption_hourly", "Наименование файла", value = "Climate_data_hourly"),
            downloadButton("download", "Скачать"),
            br(),
            mainPanel(
              tags$label(h3("Данные")),
              tags$hr(),
              tableOutput("printtable") %>% withSpinner(color = "#6fc50d")
            )
          )
        ),

        # Второе вложение
        tabItem(
          tabName = "temperature_daily",
          box(
            width = "100%",
            HTML("<h3>Изменяемые параметры</h3>"),
            sidebarPanel(
              width = "100%",
              selectInput("region_seek_daily", "Регионы", choices = unique(y$region)),
              selectInput("station_seek_daily", "Станции", choices = NULL),
            ),
            # h6("Формат даты : yyyy-mm-dd."),
            h6("При вводе даты с клавиатуры разделитель может быть любой, например, пробел, по окончании необходимо нажать enter."),
            dateInput("date_daily_start", "Начальная дата:", min = "2013-01-01", value = "2022-02-21", format = "yyyy-mm-dd"),
            dateInput("date_daily_end", "Конечная дата:", min = "2013-01-01", value = "2022-03-21", format = "yyyy-mm-dd"),
            HTML("<h3>Изменить параметр графика</h3>"),
            selectInput("param_daily",
              label = "Абсцисса",
              choices = list(
                "Average air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCAvg",
                "Maximum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMax",
                "Minimum air temperature at 2 metres above ground level. Values given in Celsius degrees" = "TemperatureCMin",
                "Average dew point temperature at 2 metres above ground level. Values given in Celsius degrees" = "TdAvgC"
              ),
              selected = "Average air temperature at 2 metres above ground level. Values given in Celsius degrees"
            ),
            actionButton("submitbutton_daily", "Показать"),
            br(),
            HTML("<h3>Скачать файл с данными</h3>"),
            textInput("caption_daily", "Наименование файла", value = "Climate_data_daily"),
            downloadButton("download_daily", "Скачать"),
            br(),
            mainPanel(
              tags$label(h3("График средней температуры по заданному интервалу времени")),
              plotlyOutput("printplot_daily") %>% withSpinner(color = "#6fc50d"),
              tags$hr(),
              tableOutput("printtable_daily") %>% withSpinner(color = "#6fc50d")
            )
          )
        ),

        # Третье вложение
        tabItem(
          tabName = "temperature_monthly",
          box(
            width = "100%",
            HTML("<h3>Изменяемые параметры</h3>"),
            sidebarPanel(
              width = "100%",
              selectInput("region_seek_monthly", "Регионы", choices = unique(y$region)),
              selectInput("station_seek_monthly", "Станции", choices = NULL),
            ),
            # textInput("year", label = h5("Год"), value = "2022"),
            h6("Формат даты : yyyy-mm-dd."),
            h6("При вводе даты с клавиатуры разделитель может быть любой, по окончании необходимо нажать enter."),
            dateInput("date_monthly_start", "Начальная дата:", min = "2013-01-01", value = "2021-02-01", format = "yyyy-mm-dd"),
            h6("Начальная дата – первое число месяца"),
            dateInput("date_monthly_end", "Конечная дата:", min = "2013-01-01", value = "2021-12-31", format = "yyyy-mm-dd"),
            h6("Конечная дата – последний день месяца"),
            # selectInput("month_from", label = "С",
            #            choices = list("January" = "01", "February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12")),
            # selectInput("month_to", label = "По (включая)",
            #            choices = list("February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12"))
            actionButton("submitbutton_monthly", "Показать"),
            br(),
            HTML("<h3>Скачать файл с данными</h3>"),
            textInput("caption_monthly", "Наименование файла", value = "Climate_data_montly"),
            downloadButton("download_montly", "Скачать"),
            br(),
            mainPanel(
              # tags$label(h3('График средней температуры по заданному интервалу времени')),
              # plotlyOutput("printplot_monthly") %>% withSpinner(color="#6fc50d"),
              tags$hr(),
              tableOutput("printtable_monthly") %>% withSpinner(color = "#6fc50d")
            )
          )
        ),


        # Четвертая вложение
        tabItem(
          tabName = "temperature_yearly",
          box(
            width = "100%",
            HTML("<h3>Изменяемые параметры</h3>"),
            sidebarPanel(
              width = "100%",
              selectInput("region_seek_yearly", "Регионы", choices = unique(y$region)),
              selectInput("station_seek_yearly", "Станции", choices = NULL),
            ),
            # textInput("year", label = h5("Год"), value = "2022"),
            # h6("Формат даты : yyyy-mm-dd."),
            # h6("При вводе даты с клавиатуры разделитель может быть любой, по окончании необходимо нажать enter."),
            # dateInput("date_yearly_start", "Начальная дата:", min = "2013-01-01", value = "2021-02-01", format = "yyyy-mm-dd"),
            selectInput("date_yearly_start",
              label = "Начальный год:",
              choices = list(
                "2013" = "2013-01-01", "2014" = "2014-01-01", "2015" = "2015-01-01", "2016" = "2016-01-01",
                "2017" = "2017-01-01", "2018" = "2018-01-01", "2019" = "2019-01-01", "2020" = "2020-01-01",
                "2021" = "2021-01-01"
              ),
              selected = "2017"
            ),
            # h6("Начальная дата – первое число месяца"),
            # dateInput("date_yearly_end", "Конечная дата:", min = "2013-01-01", value = "2021-12-31", format = "yyyy-mm-dd"),
            selectInput("date_yearly_end",
              label = "Конечный год:",
              choices = list(
                "2013" = "2013-12-31", "2014" = "2014-12-31", "2015" = "2015-12-31", "2016" = "2016-12-31",
                "2017" = "2017-12-31", "2018" = "2018-12-31", "2019" = "2019-12-31", "2020" = "2020-12-31",
                "2021" = "2021-12-31"
              ),
              selected = "2020"
            ),
            # h6("Конечная дата – последний день месяца"),
            # selectInput("month_from", label = "С",
            #            choices = list("January" = "01", "February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12")),
            # selectInput("month_to", label = "По (включая)",
            #            choices = list("February" = "02", "March" = "03", "April" = "04", "May" = "05", "June" = "06", "July" = "07", "August" = "08", "September" = "09", "October" = "10", "November" = "11", "December" = "12"))
            actionButton("submitbutton_yearly", "Показать"),
            br(),
            HTML("<h3>Скачать файл с данными</h3>"),
            textInput("caption_yearly", "Наименование файла", value = "Climate_data_yearly"),
            downloadButton("download_yearly", "Скачать"),
            br(),
            mainPanel(
              tags$label(h3("График средней температуры по заданному интервалу времени")),
              plotlyOutput("printplot_yearly") %>% withSpinner(color = "#6fc50d"),
              tags$hr(),
              tableOutput("printtable_yearly") %>% withSpinner(color = "#6fc50d")
            )
          )
        ),

        # Пятая вкладка
        tabItem(
          tabName = "station_tab",
          h2("Станции России"),
          box(
            width = "100%",
            h3("Долгота"),
            textInput("from", label = h5("От"), value = "30"),
            textInput("to", label = h5("До"), value = "85"),
            actionButton("submitbutton_station", "Показать"),
            br(),
            mainPanel(
              tags$label(h3("Данные")),
              leafletOutput("printplot_map") %>% withSpinner(color = "#6fc50d"),
              tags$hr(),
              tableOutput("printtable_station") %>% withSpinner(color = "#6fc50d")
            )
          )
        )
      )
    )
  )
)

ui <- secure_app(page, enable_admin = TRUE)

server <- function(input, output, session) {
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)
  )

  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })

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

  f_region_seek_monthly <- reactive({
    req(input$region_seek_monthly)
    filter(y, region == input$region_seek_monthly)
  })
  f_station_seek_monthly <- reactive({
    req(input$station_seek_monthly)
    filter(f_region_seek_monthly(), station == input$station_seek_monthly)
  })

  observeEvent(f_region_seek_monthly(), {
    updateSelectInput(session, "station_seek_monthly", choices = unique(f_region_seek_monthly()$station), selected = character())
  })

  f_region_seek_yearly <- reactive({
    req(input$region_seek_yearly)
    filter(y, region == input$region_seek_yearly)
  })
  f_station_seek_yearly <- reactive({
    req(input$station_seek_yearly)
    filter(f_region_seek_yearly(), station == input$station_seek_yearly)
  })

  observeEvent(f_region_seek_yearly(), {
    updateSelectInput(session, "station_seek_yearly", choices = unique(f_region_seek_yearly()$station), selected = character())
  })

  data <- eventReactive(input$submitbutton, {
    rnorm(1:100000)
  })

  # Plot Daily
  output$printplot_daily <- renderPlotly({
    input$submitbutton

    daf_daily <- data.frame(
      Name = c(
        "station_seek_daily",
        "date_daily_start",
        "date_daily_end",
        "param_daily",
        "caption_daily"
      ),
      Value = as.character(c(
        input$station_seek_daily,
        input$date_daily_start,
        input$date_daily_end,
        input$param_daily,
        input$caption_daily
      )),
      stringsAsFactors = FALSE
    )

    num_station_daily <- subset(y, station == input$station_seek_daily)

    df <- meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(num_station_daily[3]))
    data1 <- data.frame(df[names(df) == input$param_daily], df[2])
    if (input$param_daily == "TemperatureCAvg") {
      fig1 <- plot_ly(data1, x = ~Date, y = ~TemperatureCAvg) %>%
        add_lines()
    } else if (input$param_daily == "TemperatureCMax") {
      fig1 <- plot_ly(data1, x = ~Date, y = ~TemperatureCMax) %>%
        add_lines()
      fig1
    } else if (input$param_daily == "TemperatureCMin") {
      fig1 <- plot_ly(data1, x = ~Date, y = ~TemperatureCMin) %>%
        add_lines()
      fig1
    } else {
      fig1 <- plot_ly(data1, x = ~Date, y = ~TdAvgC) %>%
        add_lines()
      fig1
    }
    fig1
  })

  # Data Table Daily
  data_daily_print <- eventReactive(input$submitbutton_daily, {
    num_station_daily <- subset(y, station == input$station_seek_daily)

    df <- meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(num_station_daily[3]))

    df1 <- df[2]

    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])

    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
  })

  # Data Table Daily on click button
  output$printtable_daily <- renderTable({
    data_daily_print()
  })

  # Data Table Hourly
  data_hourly_print <- eventReactive(input$submitbutton, {
    daf_hourly <- data.frame(
      Name = c(
        "station_seek_hourly",
        "date_hourly_start",
        "date_hourly_end",
        "caption_hourly"
      ),
      Value = as.character(c(
        input$station_seek_hourly,
        input$date_hourly_start,
        input$date_hourly_end,
        input$caption_hourly
      )),
      stringsAsFactors = FALSE
    )

    num_station_hourly <- subset(y, station == input$station_seek_hourly)

    df <- meteo_ogimet(interval = "hourly", date = c(input$date_hourly_start, input$date_hourly_end), station = as.numeric(num_station_hourly[3]))

    df1 <- df[2]

    data <- data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])

    data.frame(format(df1, format = "%d %m %Y"), df[3:9], df[11], df[13:17])
  })

  # Data Table Hourly on click button
  output$printtable <- renderTable({
    data_hourly_print()
  })

  # Download data hourly
  output$download <- downloadHandler(
    filename = function() {
      paste(input$caption_hourly, Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(meteo_ogimet(interval = "hourly", date = c(input$date_hourly_start, input$date_hourly_end), station = as.numeric(subset(y, station == input$station_seek_hourly)[3])), file)
    }
  )

  # Download data daily
  output$download_daily <- downloadHandler(
    filename = function() {
      paste(input$caption, Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(meteo_ogimet(interval = "daily", date = c(input$date_daily_start, input$date_daily_end), station = as.numeric(subset(y, station == input$station_seek_daily)[3])), file)
    }
  )

  # Plot monthly
  output$printplot_monthly <- renderPlotly({
    input$submitbutton

    daf_daily <- data.frame(
      Name = c(
        "date_monthly_start",
        "date_monthly_end",
        "caption_monthly"
      ),
      Value = as.character(c(
        input$date_monthly_start,
        input$date_monthly_end,
        input$caption_monthly
      )),
      stringsAsFactors = FALSE
    )

    num_station_monthly <- subset(y, station == input$station_seek_monthly)

    df <- meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = as.numeric(num_station_monthly[3]))

    hobofull <- df %>%
      tidyr::separate("Date",
        into = c("year", "month", "day"),
        sep = "-",
        remove = FALSE
      )

    hobofull$x <- paste(hobofull$year, "-", hobofull$month)

    hobofullmean <- hobofull %>%
      group_by(x) %>%
      summarise(meantemp = mean(TemperatureCAvg, na.rm = TRUE))

    fig1 <- plot_ly(hobofullmean, x = ~x, y = ~meantemp) %>%
      add_lines()
    fig1
  })

  # Data Table Monthly
  table_monthly_print <- eventReactive(input$submitbutton_monthly, {
    num_station_monthly <- subset(y, station == input$station_seek_monthly)

    df_monthly <- meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = as.numeric(num_station_monthly[3]))

    hobofull <- df_monthly %>%
      tidyr::separate("Date",
        into = c("year", "month", "day"),
        sep = "-",
        remove = FALSE
      )

    hobofullmean <- hobofull %>%
      group_by(year, month) %>%
      summarise(meantemp = mean(TemperatureCAvg, na.rm = TRUE))

    hobofullmean
  })

  # Data Table Monthly on click button
  output$printtable_monthly <- renderTable({
    table_monthly_print()
  })

  # Download data montly
  output$download_montly <- downloadHandler(
    filename = function() {
      paste(input$caption_monthly, Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(
        hobofullmean <- meteo_ogimet(interval = "daily", date = c(input$date_monthly_start, input$date_monthly_end), station = as.numeric(subset(y, station == input$station_seek_monthly)[3])) %>%
          tidyr::separate("Date",
            into = c("year", "month", "day"),
            sep = "-",
            remove = FALSE
          ) %>%
          group_by(year, month) %>%
          summarise(meantemp = mean(TemperatureCAvg, na.rm = TRUE)),
        file
      )
    }
  )

  # Plot yearly
  output$printplot_yearly <- renderPlotly({
    input$submitbutton

    daf_yearly <- data.frame(
      Name = c(
        "date_yearly_start",
        "date_yearly_end",
        "caption_yearly"
      ),
      Value = as.character(c(
        input$date_yearly_start,
        input$date_yearly_end,
        input$caption_yearly
      )),
      stringsAsFactors = FALSE
    )

    num_station_yearly <- subset(y, station == input$station_seek_yearly)

    df <- meteo_ogimet(interval = "daily", date = c(input$date_yearly_start, input$date_yearly_end), station = as.numeric(num_station_yearly[3]))

    hobofull <- df %>%
      tidyr::separate("Date",
        into = c("year", "month", "day"),
        sep = "-",
        remove = FALSE
      )
    hobofullmean_year <- hobofull %>%
      group_by(year) %>%
      summarise(meantemp = mean(TemperatureCAvg, na.rm = TRUE))

    # hobofullmean_year$x <- paste(hobofullmean$year)

    fig1 <- plot_ly(hobofullmean_year, x = ~year, y = ~meantemp) %>%
      add_lines()
    fig1
  })

  # Data Table Yearly
  table_yearly_print <- eventReactive(input$submitbutton_yearly, {
    num_station_yearly <- subset(y, station == input$station_seek_yearly)

    df_yearly <- meteo_ogimet(interval = "daily", date = c(input$date_yearly_start, input$date_yearly_end), station = as.numeric(num_station_yearly[3]))

    hobofull <- df_yearly %>%
      tidyr::separate("Date",
        into = c("year", "month", "day"),
        sep = "-",
        remove = FALSE
      )

    hobofullmean_year <- hobofull %>%
      group_by(year) %>%
      summarise(meantemp = mean(TemperatureCAvg, na.rm = TRUE))

    hobofullmean_year
  })

  # Data Table Yearly on click button
  output$printtable_yearly <- renderTable({
    table_yearly_print()
  })

  # Download data yearly
  output$download_yearly <- downloadHandler(
    filename = function() {
      paste(input$caption_yearly, Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(
        hobofullmean_year <- meteo_ogimet(interval = "daily", date = c(input$date_yearly_start, input$date_yearly_end), station = as.numeric(subset(y, station == input$station_seek_yearly)[3])) %>%
          tidyr::separate("Date",
            into = c("year", "month", "day"),
            sep = "-",
            remove = FALSE
          ) %>%
          group_by(year) %>%
          summarise(
            meantemp = mean(TemperatureCAvg, na.rm = TRUE), meantempCMax = mean(TemperatureCMax, na.rm = TRUE),
            meantempCMin = mean(TemperatureCMin, na.rm = TRUE), meanTdAvgC = mean(TdAvgC, na.rm = TRUE)
          ),
        file
      )
    }
  )

  # Data Table Station
  data_station_print <- eventReactive(input$submitbutton_station, {
    daf_station <- data.frame(
      Name = c(
        "from",
        "to"
      ),
      Value = as.character(c(
        input$from,
        input$to
      )),
      stringsAsFactors = FALSE
    )


    nearest_stations_ogimet(
      country = "Russia",
      date = Sys.Date(),
      point = c(input$from, input$to),
      no_of_stations = 600
    )
  })

  # Data Table Station on click button
  output$printtable_station <- renderTable({
    data_station_print()
  })

  # Stations on a map
  data_station_print_map <- eventReactive(input$submitbutton_station, {
    daf_station <- data.frame(
      Name = c(
        "from",
        "to"
      ),
      Value = as.character(c(
        input$from,
        input$to
      )),
      stringsAsFactors = FALSE
    )


    k <- leaflet::leaflet(nearest_stations_ogimet(
      country = "Russia",
      date = Sys.Date(),
      point = c(input$from, input$to),
      no_of_stations = 600
    )) %>%
      addTiles() %>%
      addMarkers(~lon, ~lat, popup = ~ as.character(station_names), label = ~ as.character(station_names))
    k
  })

  # Stations on a map on click button
  output$printplot_map <- renderLeaflet({
    data_station_print_map()
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
