FROM rocker/tidyverse:latest

MAINTAINER Wouter Saelens "wouter.saelens@gmail.com"

# install shiny server dependencies
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libxml2 \
    libxml2-dev

# download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

# install xtail for logging through docker logs
RUN apt-get install -y xtail

# install dynguidelines
RUN R -e "devtools::install_github('dynverse/dynguidelines@devel', dep = TRUE)"

# copy over files of the server and the app
EXPOSE 8080
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY ./server.R /srv/shiny-server/
COPY ./ui.R /srv/shiny-server/

# define run command
CMD ["sh", "/usr/bin/shiny-server.sh"]

# reinstall dynguidelines after caching
ARG CACHE_DATE=not_a_date
RUN R -e "devtools::install_github('dynverse/dynguidelines@devel', dep = TRUE)"