#!/bin/bash

DEPLOYMENT_SOURCES="deployment_types_samples"

print_and_wait -C "Let's now see canary deployments in action"
echo

print_and_wait "Make sure that the 'minikube tunnel' is running for this script to work correctly."
print_and_wait "We'll first create the docker containers manually, both versions 1.0 and 2.0"
execute_command docker build -t catissimo:1.0 deployment_types_samples/code/v1
execute_command docker build -t catissimo:2.0 deployment_types_samples/code/v2

print_and_wait "Now we deploy canary updates, but first clear the screen."
print_and_wait -C "Canary Updates"
print_and_wait "We have a sample node application that prints a different message for each version of the release. Notice that we utilize a track label to distinguish between deployment types."
execute_command cat "${DEPLOYMENT_SOURCES}/canary_updates/v1.deployment.yaml"
execute_command cat "${DEPLOYMENT_SOURCES}/canary_updates/v2.deployment.yaml"

execute_command kubectl create -f "${DEPLOYMENT_SOURCES}/canary_updates/v1.deployment.yaml"

print_and_wait "Let's expose the deployment to be accessible from the outside."
execute_command kubectl create -f "${DEPLOYMENT_SOURCES}/canary_updates/loadbalancer.service.yaml"
execute_command kubectl get svc

print_and_wait "And let's verify it"
execute_command "curl `minikube service catissimo-lb --url` && echo; echo"

print_and_wait "Now we will deploy the canary release. We will start issuing requests to the exposed service and see if any of the requests are the new canary ones. Based on our config and the ratio of replicas, we might get only a few."
execute_command kubectl create -f "${DEPLOYMENT_SOURCES}/canary_updates/v2.deployment.yaml" --save-config
print_and_wait --no-wait "running 10 curl (minikube tunnel with service url: `minikube service catissimo-lb --url`)."

for i in {1..10}; do
  curl `minikube service catissimo-lb --url` && echo
  sleep 0.1	# 100 millisec
done
echo

print_and_wait "We should see most of the requests being handled by version 1 and some of them by version 2 of our application."

print_and_wait "If we wanted to perform full upgrade, we would need to adjust our config file from canary to stable with full number of replicas. Using scale for change this time."
execute_command kubectl scale -f "${DEPLOYMENT_SOURCES}/canary_updates/v2.deployment.yaml" --replicas=4

print_and_wait "Notice the deployed resources: this type of deployment consumes much more than the default (rolling updates)"
execute_command kubectl get all

print_and_wait "To finalize the deployment, we now only need to remove the previous deployment."
execute_command kubectl delete -f "${DEPLOYMENT_SOURCES}/canary_updates/v1.deployment.yaml"

print_and_wait "Accessing the application should now only reveal the new version v2:"
for i in {1..10}; do
  curl `minikube service catissimo-lb --url` && echo
  sleep 0.1	# 100 millisec
done
echo

print_and_wait "Final cleanup"
execute_command kubectl delete -f "${DEPLOYMENT_SOURCES}/canary_updates/v2.deployment.yaml"
execute_command kubectl delete -f "${DEPLOYMENT_SOURCES}/canary_updates/loadbalancer.service.yaml"
print_and_wait "Wait for the deployments to be fully removed and continue with CTRL+C."
kubectl get pods --watch
execute_command docker image rm catissimo:1.0
execute_command docker image rm catissimo:2.0

