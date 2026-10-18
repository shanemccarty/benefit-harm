# Helping & Aggressing: adolescents' conceptions of social behavior (v3 look and feel)
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)

dat <- read.csv("Coordinates.csv")

# Vignette shown on hover: one per group x behavior (Supplementary Tables 5-8)
vig <- read.csv("Vignettes.csv", encoding = "UTF-8")
dat <- left_join(dat, vig[, c("Gender", "PowerType", "Title", "PowerDyad", "Vignette")],
                 by = c("Gender", "PowerType", "Title", "PowerDyad"))
dat$Tip <- vapply(dat$Vignette, function(v) paste(strwrap(v, width = 55), collapse = "<br>"), "")
dat$Gender     <- as.factor(dat$Gender)
dat$PowerType  <- as.factor(dat$PowerType)
dat$PowerDyad  <- as.factor(dat$PowerDyad)
dat$Title <- factor(dat$Title, levels = c("Benefitting Extremely", "Benefitting Moderately",
                                          "Neutral", "Harming Moderately", "Harming Extremely"))

pal <- c("Benefitting Extremely" = "#1b3a8a", "Benefitting Moderately" = "#3b82f6",
         "Neutral" = "#8b5cf6", "Harming Moderately" = "#f87171", "Harming Extremely" = "#b91c1c")

legend_key <- tagList(lapply(names(pal), function(n)
  div(span(style = paste0("display:inline-block;width:12px;height:12px;border-radius:50%;margin-right:8px;background:", pal[[n]])),
       n, class = "small mb-1")))

power_desc <- c(
  "Academic Power" = "Based on academic status: honors vs. non-honors students.",
  "Social Power"   = "Based on family status: generational residence vs. recent residence.")

theme <- bs_theme(version = 5, bootswatch = "flatly",
                  base_font = font_google("Open Sans"),
                  primary = "#1b3a8a",
                  "link-color" = "#4f6364", "link-hover-color" = "#3f5152")


# Plain-language summaries of McCarty & Dunsmore (2023), Results section.
# One finding per group (gender x power type) per model (1, 2, or 3 dimensions).
findings <- list(
  "Male|Academic Power" = c(
    "Boys see helping and harming as opposite ends of one scale: helpful behaviors fall at one end, harmful behaviors at the other, and neutral behaviors in between.",
    "Boys sort behaviors by helpful versus harmful and by extent of impact. Neutral behaviors fall at the no-impact end, and helping and harming behaviors fall at the impact end.",
    "The third dimension reflects the combined status of the two students. Interactions between two low-status students fall at one end, interactions between two high-status students fall at the other, and mixed-status pairs are unrelated to it."),
  "Male|Social Power" = c(
    "Boys see helping and harming as opposite ends of one scale. Moderately and extremely helpful behaviors cluster together at the beneficial end, while harming behaviors form a continuum that separates moderately harmful from extremely harmful ones.",
    "Boys sort behaviors by helpful versus harmful and by extent of impact. Neutral behaviors fall at the no-impact end, and strongly helpful and harmful behaviors fall at the impact end.",
    "The third dimension reflects degree of harm: extremely harmful behaviors fall at the high-harm end and moderately harmful behaviors at the low-harm end. The paper's four-dimension solution for this group includes the combined status of the two students as a fourth dimension."),
  "Female|Academic Power" = c(
    "Girls' views run from harming behaviors at one end to helping behaviors at the other. Neutral behaviors fall near the helping behaviors instead of at the midpoint of the scale.",
    "Girls sort behaviors by helpful versus harmful and by extent of impact. Neutral behaviors fall at the no-impact end, and most helping and harming behaviors fall at the impact end.",
    "The third dimension reflects intensity: moderate behaviors fall toward one end and extreme behaviors toward the other."),
  "Female|Social Power" = c(
    "Girls see helping and harming as opposite ends of one scale. Moderately and extremely helpful behaviors cluster together at the beneficial end, while harming behaviors form a continuum that separates moderately harmful from extremely harmful ones.",
    "Girls sort behaviors by helpful versus harmful and by extent of impact. Neutral behaviors fall at the no-impact end, and helping and harming behaviors fall toward the impact end.",
    "The third dimension reflects the combined status of the two students, with low-status pairs at one end and high-status pairs at the other. The paper's four-dimension solution for this group includes the relative power between the two students as a fourth dimension."))

doi_url <- "https://doi.org/10.1007/s12144-022-03806-4"

green_css <- "
  .showing-bar { background:#667a7b; color:#fff; border:0; }
  .accordion { --bs-accordion-active-bg:#dfe6e6; --bs-accordion-active-color:#3f5152;
               --bs-accordion-btn-focus-box-shadow:0 0 0 .2rem rgba(102,122,123,.25); }
  .accordion-button:not(.collapsed) { background-color:#dfe6e6; color:#3f5152; }
  .findings-card .card-header { background:#eef2f2; color:#3f5152; border-bottom:1px solid #cbd5d5; }
  .findings-card { border-color:#cbd5d5; }
"

ui <- page_sidebar(
  tags$head(tags$style(HTML(green_css))),
  window_title = "Benefit-Harm",
  title = "Adolescents' Conceptions of Social Behaviors",
  theme = theme,
  fillable = FALSE,
  sidebar = sidebar(
    width = 320,
    h5("Explore the data"),
    p(class = "text-muted small",
      "Pick a group below to see how adolescents sort 20 social behaviors (8 helping, 8 aggressing, 4 neutral) from beneficial to harmful. The plots update as you choose."),
    card(
      card_header("Choose a group to explore"),
      radioButtons("PowerType", "1. Type of power",
                   c("Academic Power", "Social Power")),
      uiOutput("power_desc"),
      radioButtons("Gender", "2. Gender identity",
                   c("Man" = "Male", "Woman" = "Female"), inline = TRUE)
    ),
    card(
      card_header("Color key"),
      legend_key
    )
  ),
  uiOutput("showing"),
  accordion(
    open = "intro",
    accordion_panel(
      "Introduction", value = "intro",
      p("Academics' conceptions of social behavior often take precedence over youth conceptions. To bridge this gap, we examine adolescents' perceptions of helping, aggressing, and bullying to identify dimensions most salient to them.")
    )
  ),
  uiOutput("findings"),
  navset_card_tab(
    id = "model",
    title = "Dimensions",
    nav_panel("1 dimension", value = "1",
              p(class = "text-muted small", "Hover over a point for details."),
              plotlyOutput("Dim1Plot", height = "340px")),
    nav_panel("2 dimensions", value = "2",
              p(class = "text-muted",
                "We hypothesized relative power would emerge as the second dimension. Rather, extent of impact emerged, distinguishing neutral behaviors from behaviors of impact. Hover over a point for details."),
              p(class = "small", strong("Shapes (agent - recipient power): "),
                "\u25b2 High-High \u00a0 \u25bd High-Low \u00a0 \u25b3 Low-High \u00a0 \u25c6 Low-Low"),
              plotlyOutput("Dim2Plot", height = "560px")),
    nav_panel("3 dimensions", value = "3",
              p(class = "text-muted small", "Drag to rotate; hover over a point for details."),
              plotlyOutput("Dim3Plot", height = "560px"))
  ),
  card(
    card_header("About"),
    tags$ul(
      tags$li(strong("v1: "), "Created Spring 2021 by Shane McCarty and Bryan Acton using RStudio 1.3.1056 and Shiny 1.6.0."),
      tags$li(strong("v2: "), "Updated with Claude Sonnet 5.5 in Fall 2026.")
    ),
    p("This app complements a published manuscript:"),
    p("McCarty, S.M., & Dunsmore, J.C. (2023). Adolescents\u2019 perceptions of helping and aggressing at school: Salience of benefit-harm, extent of impact, and collective dyadic power. Current Psychology, 42(31), 27153-27166. ",
      tags$a(doi_url, href = doi_url, target = "_blank"))
  )
)

server <- function(input, output, session) {

  output$power_desc <- renderUI(
    p(class = "text-muted small", style = "margin-top:-0.5rem;", power_desc[[input$PowerType]]))

  output$showing <- renderUI({
    who <- if (input$Gender == "Male") "Boys" else "Girls"
    div(class = "alert showing-bar py-2",
        strong("Showing: "), input$PowerType, " for ", who)
  })

  output$findings <- renderUI({
    k <- as.integer(req(input$model))
    key <- paste(input$Gender, input$PowerType, sep = "|")
    who <- if (input$Gender == "Male") "boys" else "girls"
    card(
      class = "findings-card",
      card_header(strong(paste0("Key findings for the ", k, "-dimensional model of ",
                                tolower(input$PowerType), " for ", who, ":"))),
      p(findings[[key]][k]),
      p(class = "small text-muted mb-0",
        "Summarized from McCarty & Dunsmore (2023), ", tags$a("doi", href = doi_url, target = "_blank"), ".")
    )
  })

  sub <- function(k) reactive({
    dat |> filter(Gender == input$Gender, PowerType == input$PowerType, Dimensions == k)
  })
  d1 <- sub(1); d2 <- sub(2); d3 <- sub(3)

  output$Dim1Plot <- renderPlotly({
    d <- d1()
    p <- ggplot(d, aes(Dim1, 0, colour = Title,
                       text = paste0("<b>", Title, "</b> (", PowerDyad, ")<br>Dim 1: ", Dim1, "<br><br>", Tip))) +
      geom_point(size = 3.5, alpha = .85) +
      scale_colour_manual(values = pal, drop = FALSE) +
      labs(x = "Beneficial to Harmful", y = NULL, colour = NULL) +
      theme_minimal(base_size = 13) +
      theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank(),
            panel.grid.minor = element_blank())
    ggplotly(p, tooltip = "text") |> layout(legend = list(orientation = "h", y = -0.55), margin = list(b = 110))
  })

  dyad_symbol <- c("High-High" = "triangle-up", "High-Low" = "triangle-down-open",
                   "Low-High" = "triangle-up-open", "Low-Low" = "diamond")

  output$Dim2Plot <- renderPlotly({
    d <- d2()
    d$sym <- unname(dyad_symbol[as.character(d$PowerDyad)])
    plot_ly(d, x = ~Dim1, y = ~Dim2, color = ~Title, colors = pal,
            type = "scatter", mode = "markers",
            marker = list(size = 12, symbol = ~sym, line = list(width = 2)),
            text = ~paste0("<b>", Title, "</b> (", PowerDyad, ")<br><br>", Tip), hoverinfo = "text") |>
      layout(xaxis = list(title = "Beneficial to Harmful", zeroline = FALSE),
             yaxis = list(title = "Extent of Impact", zeroline = FALSE),
             legend = list(orientation = "h", y = -0.18), margin = list(b = 100))
  })

  output$Dim3Plot <- renderPlotly({
    d <- d3()
    plot_ly(d, x = ~Dim1, y = ~Dim2, z = ~Dim3, color = ~Title, colors = pal,
            type = "scatter3d", mode = "markers", marker = list(size = 4),
            text = ~paste0("<b>", Title, "</b> (", PowerDyad, ")<br><br>", Tip), hoverinfo = "text") |>
      layout(scene = list(xaxis = list(title = "Beneficial to Harmful"),
                          yaxis = list(title = "Extent of Impact"),
                          zaxis = list(title = "Dimension 3")),
             legend = list(orientation = "h"))
  })
}

shinyApp(ui, server)
