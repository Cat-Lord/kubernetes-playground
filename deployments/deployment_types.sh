#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"
DEPLOYMENT_SOURCES="deployment_types_samples"

print_and_wait -c "Let's now create multiple various deployments and see how they act when we apply changes to them."
echo

print_and_wait "Make sure that the 'minikube tunnel' is running for this script to work correctly."
print_and_wait "We'll first create the docker containers manually, both versions 1.0 and 2.0"
execute_command docker build -t catissimo:1.0 deployment_types_samples/code/v1
execute_command docker build -t catissimo:2.0 deployment_types_samples/code/v2

print_and_wait "Let's start with rolling updates, but first clear the screen."
print_and_wait -c "Starting with the default: Rolling Updates"
print_and_wait "We have a sample node application that prints a different message for each version of the release."
execute_command cat "${DEPLOYMENT_SOURCES}/rolling_updates/v1.deployment.yaml"

print_and_wait "Version 2 is almost identical. Notice that the container name is changes for easier identification."
execute_command cat "${DEPLOYMENT_SOURCES}/rolling_updates/v2.deployment.yaml"

execute_command kubectl create -f "${DEPLOYMENT_SOURCES}/rolling_updates/v1.deployment.yaml" --save-config
# TODO: handling quoted arguments fails here
echo 'kubectl annotate deployment catissimo kubernetes.io/change-cause="initial deployment, v1.0"'
kubectl annotate deployment catissimo kubernetes.io/change-cause="initial deployment, v1.0"

print_and_wait "Deployment history now shows one revision:"
execute_command kubectl rollout history deployment catissimo

print_and_wait "Let's see resources created"
execute_command kubectl get all

print_and_wait "Let's expose the deployment to be accessible from the outside."
execute_command kubectl expose deployment catissimo --type=LoadBalancer --port=8081 --target-port=8080
execute_command kubectl get svc

print_and_wait "And let's verify it"
echo "curl `minikube service catissimo --url` && echo"
curl `minikube service catissimo --url` && echo; echo;

print_and_wait "Now focus: we are going to deploy the version 2, but without waiting. We're immediately going to perform a regular curl requests to the exposed service we created above."
echo "kubectl apply -f ${DEPLOYMENT_SOURCES}/rolling_updates/v2.deployment.yaml"
kubectl apply -f "${DEPLOYMENT_SOURCES}/rolling_updates/v2.deployment.yaml"
echo
echo 'kubectl annotate deployment catissimo kubernetes.io/change-cause="upgrade to v2.0"'
kubectl annotate deployment catissimo kubernetes.io/change-cause="upgrade to v2.0"
echo
echo "running curl in loop (minikube tunnel with service url: `minikube service catissimo --url`). Continue with CTRL + C."

TEST_DEPLOYMENT=true
trap 'TEST_DEPLOYMENT=false' SIGINT 
while ${TEST_DEPLOYMENT}; do
  curl `minikube service catissimo --url` && echo
  sleep 0.1	# 100 millisec
done
echo

print_and_wait "After a few iterations we should see that we now get the new version of the app deployed."
print_and_wait "The history of deploment contains now more records"
execute_command kubectl rollout history deployment catissimo

print_and_wait "We can also get info about a specific revision"
execute_command kubectl rollout history deployment catissimo --revision=2

print_and_wait "In a similar fashion we can revert a deployment. If we omit the last argument we would roll back to the previous deployment."
execute_command kubectl rollout undo deployment catissimo --to-revision=1

print_and_wait "Let's verify it with a curl command"
curl `minikube service catissimo --url` && echo; echo;

print_and_wait "Final cleanup"
execute_command kubectl delete all --all --now
execute_command docker image rm catissimo:1.0
execute_command docker image rm catissimo:2.0

