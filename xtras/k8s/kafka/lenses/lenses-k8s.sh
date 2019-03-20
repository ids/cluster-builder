kubectl create ns kafka
kubectl apply -f 010-lenses-svc.yml
kubectl apply -f 015-lenses-pvc.yml

export KAFKA_IP=`kubectl get svc -o  jsonpath='{.items[*].status.loadBalancer.ingress[*].ip}'`
echo $KAFKA_IP

envsubst < 020-lenses.yml | kubectl apply -f -
