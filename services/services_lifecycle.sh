#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Let's first deploy a sample application"
print_and_wait "Application configuration:"
cat nginx.deployment.yaml; echo

execute_command kubectl apply -f nginx.deployment.yaml

print_and_wait "We can use port-forwarding to access the deployment. Navigate to localhost:8080 for verification or continue with CTRL+C."
execute_command kubectl port-forward deployment/app-deployment 8080:80

print_and_wait "Did you notice a subtle detail in the command above? We are able to port-forward not only directly to pods, but also deployments (and services)!"
print_and_wait "Let's verify that the pods can contact each other. First we need an names and IPs of a our 2 pods."

# Piping doesn't work well with the 'execute_command' utility
echo 'kubectl get pods -o name --no-headers=true | head -n 1'
kubectl get pods -o name --no-headers=true | head -n 1
POD_1_NAME=`kubectl get pods -o name --no-headers=true | head -n 1`
POD_1_IP=`kubectl get ${POD_1_NAME} --template '{{.status.podIP}}'`
echo; # spacing

echo 'kubectl get pods -o name --no-headers=true | tail -n 1'
kubectl get pods -o name --no-headers=true | tail -n 1
POD_2_NAME=`kubectl get pods -o name --no-headers=true | tail -n 1`
POD_2_IP=`kubectl get ${POD_2_NAME} --template '{{.status.podIP}}'`
echo; # spacing

echo "Pod 1: ${POD_1_NAME} | ${POD_1_IP}"
echo "Pod 2: ${POD_2_NAME} | ${POD_2_IP}"
echo; # spacing

print_and_wait "And now we trigger a simple curl command from one pod to another."
execute_command kubectl exec ${POD_1_NAME} -- curl -s http://${POD_2_IP}

print_and_wait "To access pods we can also call an exposed service"
print_and_wait "First we spin up a load-balancer service"
execute_command kubectl apply -f loadbalancer.service.yaml
sleep 2;
execute_command kubectl get services

print_and_wait "Now let's use the name of the service instead of direct IP address"
echo "kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1"
kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1; echo
SERVICE_DNS_NAME=`kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1`
execute_command kubectl exec ${POD_1_NAME} -- curl -s http://${SERVICE_DNS_NAME}:8080

print_and_wait "Let's try a nodePort service"
execute_command kubectl apply -f nodeport.service.yaml

print_and_wait "We actually need to remove our load-balancer to be able to access pods via the nodePort service."
execute_command kubectl delete service app-balancer

print_and_wait "You can now see that we can access the proxied port. If a browser doesn't open, simply navigate to localhost:30123."
execute_command sensible-browser http://localhost:30123

print_and_wait "And finally clean up resources"
execute_command kubectl delete all -l app=meowness