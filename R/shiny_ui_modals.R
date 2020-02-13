# get the modal to display the citations
get_citations_modal <- function() {
  showModal(modalDialog(
    title = tagList(
      "If ",
      HTML("<em>dyn</em>guidelines was helpful to you, please cite: "),
      tags$button(type = "button", class = "close", `data-dismiss` = "modal", "\U00D7")
    ),

    tags$div(
      style = "float:right;",

      singleton(tags$head(tags$script(type = "text/javascript", src = "https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js"))),
      tags$div(
        class = "altmetric-embed",
        `data-badge-type` = "medium-donut",
        `data-doi` = "10.1101/276907"
      ),
      tags$script("if (typeof _altmetric_embed_init !== 'undefined') {_altmetric_embed_init()};"),

      singleton(tags$head(tags$script(type = "text/javascript",src = "https://badge.dimensions.ai/badge.js"))),
      tags$div(
        class = "__dimensions_badge_embed__",
        `data-doi` = "10.1101/276907"
      ),
      tags$script("if (typeof __dimensions_embed !== 'undefined') {__dimensions_embed.addBadges()};")
    ),



    tags$a(
      href = "http://dx.doi.org/10.1101/276907",
      tags$blockquote(HTML(paste0("<p>", glue::glue_collapse(sample(c("Wouter Saelens*", "Robrecht Cannoodt*")), ", "), ", Helena Todorov, and Yvan Saeys. </p><p> \U201C A Comparison of Single-Cell Trajectory Inference Methods: Towards More Accurate and Robust Tools.\U201D </p><p> BioRxiv, March 5, 2018, 276907. </p> <p> https://doi.org/10.1101/276907 </p>"))),
      target = "blank"
    ),

    tags$p(
      style = "font-size: 17.5px;",
      "... or give us a shout-out on twitter (", tags$a(href = "https://twitter.com/saeyslab", "@saeyslab", target = "blank"), "). We'd love to hear your feedback!"
    ),

    tags$p(
      style = "font-size: 17.5px;",
      "Don't forget to also cite the papers describing the individual methods which you're using. They can be found by clicking the ", icon("paper-plane"), "icon."
    ),

    style = "overflow:visible;",

    easyClose = TRUE,
    size = "l",
    footer = NULL
  ))
}

