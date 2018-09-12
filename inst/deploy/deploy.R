# install rsconnect
if (!"rsconnect" %in% rownames(installed.packages())) {
  install.packages("rsconnect")
}

# install from github so that packrat knows the source of this package
devtools::install_github("dynverse/dynguidelines@devel", dep = F)

# load in account info
rsconnect::setAccountInfo(name="dynverse", token="88F1120902755CE3DC4BF1753546B487", secret=Sys.getenv("shinyapps_secret"))

# deploy the app
rsconnect::deployApp("inst/deploy", forceUpdate = TRUE)
