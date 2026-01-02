
# this is for local use on a mac


# 0 - docker desktop must be running
open -a Docker


# 1 - start minikube
minikube start --driver=docker

# verify cluster
kubectl get nodes


# 2 - Point Docker to Minikube’s Docker daemon
eval $(minikube docker-env)
# verify
docker info | grep -i "name"


# 3 - Build the image inside Minikube
docker build -t hello-k8s:1.0.0 .
# verify
docker images | grep hello-k8s


# 4 - deploy the app
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
# watch rollout
kubectl rollout status deployment/hello-k8s


# 5 - Confirm pods are running
kubectl get pods


# 6 - Check logs (sanity check)
kubectl logs deployment/hello-k8s


# 7 - Access the app (two working options)
## Option A: Port-forward (recommended for learning)
kubectl port-forward service/hello-k8s 8000:80
# Leave this running.
# in another terminal
# curl http://localhost:8000
# curl http://localhost:8000/health
# curl http://localhost:8000/version
## Option B: Minikube service URL
# minikube service hello-k8s --url
# test in another terminal
# curl http://127.0.0.1:xxxxx

