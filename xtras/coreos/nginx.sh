echo "Basic Nginx ingress controller requirements"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml

echo "Using NodePort Nginx for Baremetal"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml

kubectl get pods --all-namespaces -l app=ingress-nginx --watch

