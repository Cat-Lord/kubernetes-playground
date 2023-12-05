#!/bin/bash


print_and_wait -C "Deployment creation and deletion with other common basic commands."

print_and_wait "First of all let's create a deployment from a config file"
print_and_wait "Let's print the config file first"
cat basic.deployment.yaml; echo

print_and_wait "Notice a little bonus at the end - specifying resources limitations"
tail basic.deployment.yaml; echo

print_and_wait "Let's run the deployment"
execute_command kubectl apply -f basic.deployment.yaml

print_and_wait "Now verify that the deployment was successful"
execute_command kubectl get deployments
print_and_wait "Funilly enough, this command above works with 'get deploy', 'get deployment' and 'get deployments'. Choice is yours."

print_and_wait "We can also insepct all the created resources"
execute_command kubectl get all

print_and_wait "Pods will also have information assigned to them, such as what controllers control them:"
execute_command "kubectl describe pods | grep -i 'controlled by'"

print_and_wait "and inspect all available labels"
execute_command kubectl get deployments --show-labels

print_and_wait "...or get deployments based on a label"
execute_command kubectl get deployments -l app="my-nginx"

print_and_wait "We can manually scale the deployment"
execute_command kubectl scale deployment frontend --replicas=5
print_and_wait "Inpectig events we should see the scaling take place"
execute_command kubectl get event --field-selector involvedObject.name=frontend
print_and_wait "We can also look at all the resources (see the 'DESIRED' and 'CURRENT' replicaSets values)"
execute_command kubectl get replicaSet

print_and_wait "Also possible with the -f switch"
execute_command kubectl scale -f basic.deployment.yaml --replicas=2

print_and_wait "Let's see the event logs again"
execute_command kubectl get event --field-selector involvedObject.name=frontend

print_and_wait "Deployments automatically create replicaSets. Let's see it in action. We have our pods..."
execute_command kubectl get pods
print_and_wait "...and we can try deleting pods and see the replicaSet step in and initiate their recreation. (continue with CTRL+C)"
execute_command --no-wait kubectl delete pods --all
execute_command --no-wait kubectl get pods -w
print_and_wait "As we can see pods got recreated with the help of replicaSet without our intervention."
echo

print_and_wait "Deletion is also the same as with pods"
print_and_wait "Either 'kubectl delete deployment <deployment-name>' or"
execute_command kubectl delete -f basic.deployment.yaml

