#' Shiny user interface
#'
#' @export
shiny_ui <- function() {
  # add path of images
  addResourcePath("img", system.file("img/", package = "dynguidelines"))

  ## build the page ----------------------------
  fluidPage(
    title = "Selecting the most optimal TI method - dynguidelines",
    shinyjs::useShinyjs(),
    tags$head(tags$script(src = "https://www.googletagmanager.com/gtag/js?id=UA-578149-3")),
    tags$head(includeScript(system.file("js/tooltips.js", package = "dynguidelines"))),
    tags$head(includeScript(system.file("js/google-analytics.js", package = "dynguidelines"))),

    tags$head(tags$script(src = "https://cdn.jsdelivr.net/combine/npm/lodash@4.17.10,npm/intro.js@2.9.3")),

    tags$head(tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/intro.js@2.9.3/introjs.min.css")),

    tags$head(includeCSS(system.file("css/style.css", package = "dynguidelines"))),

    tags$head(tags$link(rel = "icon", type = "image/png", href = "img/favicon_16.png")),

    # navbar
    tags$nav(
      class = "navbar navbar-default navbar-fixed-top",
      div(
        class = "container-fluid",
        div(
          class = "navbar-header",
          tags$a(
            class = "",
            href = "#",
            img(src = "img/logo_horizontal.png"),
            `data-intro` = "<em>dyn</em>guidelines is an app for selecting the most optimal set of trajectory inference (TI) methods for a given use case. It uses data from a <a href='https://benchmark.dynverse.org'>comprehensive benchmarking of TI methods</a> and is part of a larger set of open packages for doing and interpreting trajectories called the <a href='https://dynverse.org'><em>dyn</em>verse</a>.",
            `data-step` = 1
          )
        ),

        div(
          class = "navbar-collapse collapse",
          tags$ul(
            class = "nav navbar-nav navbar-left",
            # tutorial
            tags$li(
              class = "nav-highlight",
              tags$a(
                "Tutorial",
                icon("question-circle"),
                href = "#intro",
                onclick="javascript:introJs().setOption('showBullets', false).setOption('scrollToElement', false).start();"
              )
            ),

            # citation
            tags$li(
              class = "nav-highlight",
              actionLink(
                "show_citation",
                tagList("Citation ", icon("quote-right"))
              )
            )
          ),
          tags$ul(
            class = "nav navbar-nav navbar-right",

            # benchmarking study
            tags$li(
              tags$a(
                "Benchmark study ",
                icon("paper-plane"),
                href = "https://doi.org/10.1101/276907",
                target = "blank"
              )
            ),

            # benchmarking repo
            tags$li(
              tags$a(
                HTML("Evaluating methods with <em>dyn</em>benchmark "),
                icon("github"),
                href = "https://github.com/dynverse/dynbenchmark",
                target = "blank"
              )
            ),

            tags$li(
              a(
                style = "display: inline;",
                href = "https://github.com/dynverse/dynverse",
                target = "blank",
                "Part of",
                img(
                  src = "img/logo_dynverse.png"
                )
              )
            )
          )
        )
      )
    ),

    div(
      style = "position:relative; width:100%; top:80px;",
      div(
        div(
          style = "width:30%",
          div(
            style = "overflow-y:scroll; position:fixed; bottom:0px; top:80px; width:inherit; padding-right: 10px;background-color:white;z-index:1;",
            uiOutput("questions_panel"),
            `data-intro` = "The choice of methods depends on the use case. These questions are designed to make deciding which method to use easier, by polling for the prior information on the trajectory, the size of the data and the execution environment.",
            `data-step` = 2
          )
        ),
        div(
          style = "width:70%;float:right;padding-left:20px;",

          # top buttons
          div(
            class = "btn-group btn-group-justified",
            # code button
            tags$a(
              class = "btn btn-default",
              style = "",
              "Show code ",
              icon("code"),
              href = "#toggle-code",
              `data-target` = "#code",
              `data-toggle` = "collapse",
              `data-intro` = "You can get the code necessary to reproduce the guidelines here. Copy it over to your script!",
              `data-step` = 4
            ),

            # columns button
            tags$a(
              class = "btn btn-default",
              style = "",
              "Show/hide columns ",
              icon("columns"),
              href = "#toggle-columns",
              `data-target` = "#columns",
              `data-toggle` = "collapse"
            ),

            # options button
            tags$a(
              class = "btn btn-default",
              style = "",
              "Options ",
              icon("gear"),
              href = "#toggle-options",
              `data-target` = "#options",
              `data-toggle` = "collapse"
            ),

            if (interactive()) {
              # submit button
              actionLink(
                class = "btn",
                "submit",
                label = span(
                  icon("share", class = "arrow4"),
                  " Close & use ",
                  icon("share", class = "arrow4")
                ),
                style = "color: white;font-weight: bold; background-color:#9362e0",
                `data-step` = 6,
                `data-intro` = "When ready, click this button to return the selected set of methods in R.",
                onclick = "window.close();"
              )
            } else {
              # dyno button
              tags$a(
                class = "btn",
                style = "color: white;font-weight: bold; background-color:#9362e0",
                span(
                  icon("share", class = "arrow4"),
                  HTML("Infer trajectories with <em>dyn</em>o"),
                  icon("share", class = "arrow4")
                ),
                href = "https://github.com/dynverse/dyno",
                `data-intro` = "All methods presented here are available in the <a href = 'https://github.com/dynverse/dyno' target = 'blank'><em>dyn</em>o pipeline</a>, which can also be used to <strong>interpret</strong> and <strong>visualise</strong> the inferred trajectories.",
                `data-step` = 6,
                target = "blank"
              )
            }
          ),

          # columns collapsible
          tags$div(
            class = "panel-collapse collapse",
            id = "columns",

            tags$div(

              # individual checkboxes
              tags$div(
                class = "indeterminate-checkbox-group",
                uiOutput("column_show_hide")
              )
            )
          ),

          # code collapible
          tags$div(
            class = "panel-collapse collapse",
            id = "code",

            # copy button
            singleton(tags$head(tags$script(src = "https://cdn.jsdelivr.net/npm/clipboard@2/dist/clipboard.min.js"))),
            tags$button(
              class = "btn btn-default btn-s btn-copy",
              style = "float:left",
              icon("copy"),
              `data-clipboard-target`="#code"
            ),
            tags$script("$(document).ready(function() {new ClipboardJS('.btn-copy')});"),

            # actual code
            textOutput("code", container = tags$pre)
          ),

          # options collapsible
          tags$div(
            class = "panel-collapse collapse",
            id = "options",

            # actual code
            uiOutput("options")
          ),

          # presets buttons
          tags$div(
            uiOutput("column_presets"),
            `data-intro` = "Here, you can change the columns displayed in the main table. It allows you to focus on particular aspects of the benchmarking, such as scalability, accuracy metrics, and usability.",
            `data-step` = 5
          ),

          # method table
          div(
            `data-intro` = "The relevant methods are displayed here, along with information on how they were ordered and selected.",
            `data-step` = 3,
            uiOutput("methods_table")
          )
        )
      )
    )
  )
}