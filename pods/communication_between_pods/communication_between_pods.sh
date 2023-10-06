#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Let's first deploy a sample application"
print_and_wait "Application configuration:"
cat nginx.deployment.yaml; echo

execute_command kubectl apply -f nginx.deployment.yaml

print_and_wait "We can use port-forwarding to access the deployment. Navigate to localhost:8080 for verification or exit with CTRL+C."
execute_command kubectl port-forward deployment/app-deployment 8080:80

print_and_wait "Did you notice a subtle detail in the command above? We are able to port-forward not only directly to pods, but also deployments (and services)!"
print_and_wait "Let's verify that the pods can contact each other. First we need an IP of a pod,"

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

print_and_wait "And now we trigger a simple curl command from one pod to another."
print_and_wait "Pod 1: ${POD_1_NAME} | ${POD_1_IP}"
print_and_wait "Pod 2: ${POD_2_NAME} | ${POD_2_IP}"
execute_command kubectl exec ${POD_1_NAME} -- curl -s http://${POD_2_IP}

