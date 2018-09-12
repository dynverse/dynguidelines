## Go to correct folder
cd inst/deploy

## Build the container
docker build -t dynverse/dynguidelines_server .

## Push the container
docker push dynverse/dynguidelines_server

## Run the container
docker run --rm -p 80:80 --name shiny dynverse/dynguidelines_server



docker tag dynverse/dynguidelines_server gcr.io/dynguidelines/dynguidelines:v1
docker push gcr.io/dynguidelines/dynguidelines:v1
kubectl set image deployment/dynguidelines dynguidelines=gcr.io/dynguidelines/dynguidelines:v1




