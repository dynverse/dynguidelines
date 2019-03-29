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

# clone dynguidelines repo
RUN git clone -b master https://github.com/dynverse/dynguidelines.git

# install dynguidelines
RUN cd dynguidelines; R -e "devtools::install(dep = TRUE)"

# copy over files of the server and the app
EXPOSE 8080
COPY server/shiny-server.sh /home/rstudio/shiny-server.sh
COPY server/shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY server/server.R /srv/shiny-server/
COPY server/ui.R /srv/shiny-server/

# define run command
CMD ["sh", "/home/rstudio/shiny-server.sh"]