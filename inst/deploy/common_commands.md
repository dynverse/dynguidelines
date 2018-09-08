## Go to correct folder
cd inst/deploy

## Build the container
docker build -t dynverse/dynguidelines_server .

## Push the container
docker push dynverse/dynguidelines_server

## Run the container
docker run --rm -p 80:80 --name shiny dynverse/dynguidelines_server