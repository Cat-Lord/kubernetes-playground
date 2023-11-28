#!/bin/bash


print_and_wait -c "Let's first deploy a sample application"
print_and_wait "Application configuration:"
cat communication.deployment.yaml; echo

execute_command kubectl apply -f communication.deployment.yaml

print_and_wait "Now we get information about both deployed pods."
execute_command "kubectl get pods -o name --no-headers=true | head -n 1"
POD_1_NAME=`kubectl get pods -o name --no-headers=true | head -n 1`
POD_1_IP=`kubectl get ${POD_1_NAME} --template '{{.status.podIP}}'`

execute_command "kubectl get pods -o name --no-headers=true | tail -n 1"
POD_2_NAME=`kubectl get pods -o name --no-headers=true | tail -n 1`
POD_2_IP=`kubectl get ${POD_2_NAME} --template '{{.status.podIP}}'`

echo "Pod 1: ${POD_1_NAME} | ${POD_1_IP}"
echo "Pod 2: ${POD_2_NAME} | ${POD_2_IP}"
echo

print_and_wait "And now we trigger a simple curl command from one pod to another."
execute_command kubectl exec ${POD_1_NAME} -- curl -s http://${POD_2_IP}

print_and_wait "Finally a cleanup"
execute_command kubectl delete -f communication.deployment.yaml

