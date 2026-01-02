
minikube delete
minikube start --driver=docker
eval $(minikube docker-env)
docker build -t hello-k8s:1.0.0 .
kubectl apply -f k8s/
kubectl port-forward service/hello-k8s 8080:80
