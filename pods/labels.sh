#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Labels and selectors in action"
execute_command kubectl apply -f labels/paw.pod.yaml
execute_command kubectl apply -f labels/meow.pod.yaml
execute_command kubectl apply -f labels/loadbalancer.service.yaml

print_and_wait "Review the created pods and load-balancer service"
execute_command kubectl get all

print_and_wait "Let's see the labels used by the pods and the service"
execute_command kubectl get pods --show-labels
execute_command kubectl describe service meowness-balancer

print_and_wait "Above you see that the service selector matches the labels of the pods. Let's clean up."
execute_command kubectl delete all -l app=cuteness
