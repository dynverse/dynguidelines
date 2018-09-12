## Go to correct folder
cd inst/deploy

## Build the container
docker build --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) -t dynverse/dynguidelines_server .

## Push the container
docker push dynverse/dynguidelines_server

## Run the container
docker run --rm -p 8080:8080 --name shiny dynverse/dynguidelines_server

## push to google cloud
# https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app
docker tag dynverse/dynguidelines_server gcr.io/dynguidelines/dynguidelines_server
docker push -- gcr.io/dynguidelines/dynguidelines_server
kubectl set image deployment/dynguidelines dynguidelines=gcr.io/dynguidelines/dynguidelines_server


docker run --rm -p 8080:8080 --name shiny gcr.io/dynguidelines/dynguidelines_server


# get ip
kubectl get service

