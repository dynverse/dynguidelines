# Kubernetes

## Set context

Make sure this is correct, otherwise everything will time out
```
kubectl config use-context gke_dynguidelines_us-central1-a_dynguidelines
```

# Rollout

## Go to correct folder
```
cd inst/deploy
```

## Change current version tag (necessary to do rolling updates on google cloud)
```
export version=`R --vanilla -e  "cat(as.character(packageVersion('dynguidelines'))[[1]]);cat('\n')" | grep "^[^>]" | tail -n 1`
echo $version
```

## Build the container
```
# without cache:
# docker build --no-cache --build-arg CACHE_DATE=$(date +%Y-%m-%d:%H:%M:%S) -t dynverse/dynguidelines_server:${version} .

# with cache
docker build -t dynverse/dynguidelines_server:${version} inst/deploy
```

## Push the container
```
docker push dynverse/dynguidelines_server:${version}
```

## Run the container locally for testing
```
docker run --rm -p 8080:8080 --name shiny dynverse/dynguidelines_server:${version}
docker kill shiny
```

## Push to google cloud

```
docker tag dynverse/dynguidelines_server:${version} gcr.io/dynguidelines/dynguidelines_server:${version}
docker push -- gcr.io/dynguidelines/dynguidelines_server:${version}
kubectl set image deployment/dynguidelines dynguidelines=gcr.io/dynguidelines/dynguidelines_server:${version}
```

## Get rollout status
```
kubectl rollout status deployment/dynguidelines
kubectl get deployments
```

# Create cluster from scratch

Add the cluster as a google cloud context:
https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app

Create the cluster
```
gcloud container clusters create dynguidelines --num-nodes=1
```

Push container (see up)

Run container
```
kubectl run dynguidelines --image=gcr.io/dynguidelines/dynguidelines_server:${version} --port 8080

kubectl expose deployment dynguidelines --type=LoadBalancer --port 80 --target-port 8080
```

## Get public ip
```
kubectl get service
```


# Continuous deployment

Create a service account: https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account

Generate key

Base 64 key
```
base64 ~/Downloads/dynguidelines-465c5aa876d4.json > /tmp/decrypted_key.json
```

Add as `GCLOUD_SERVICE_KEY` to travis environment variables