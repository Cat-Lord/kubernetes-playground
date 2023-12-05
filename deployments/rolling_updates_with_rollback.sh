#!/bin/bash

DEPLOYMENT_SOURCES="deployment_types_samples"

print_and_wait -C "Let's now create multiple various deployments and see how they act when we apply changes to them."
echo

print_and_wait "Make sure that the 'minikube tunnel' is running for this script to work correctly."
print_and_wait "We'll first create the docker containers manually, both versions 1.0 and 2.0"
execute_command docker build -t catissimo:1.0 deployment_types_samples/code/v1
execute_command docker build -t catissimo:2.0 deployment_types_samples/code/v2

print_and_wait "Let's start with rolling updates, but first clear the screen."
print_and_wait -C "Starting with the default: Rolling Updates"
print_and_wait "We have a sample node application that prints a different message for each version of the release."
execute_command cat "${DEPLOYMENT_SOURCES}/rolling_updates/v1.deployment.yaml"

print_and_wait "Version 2 is almost identical. Notice that the container name is changed for easier identification."
execute_command cat "${DEPLOYMENT_SOURCES}/rolling_updates/v2.deployment.yaml"

execute_command kubectl create -f "${DEPLOYMENT_SOURCES}/rolling_updates/v1.deployment.yaml" --save-config
execute_command 'kubectl annotate deployment catissimo kubernetes.io/change-cause="initial deployment, v1.0"'

print_and_wait "Deployment history now shows one revision:"
execute_command kubectl rollout history deployment catissimo

print_and_wait "Let's see resources created"
execute_command kubectl get all

print_and_wait "Let's expose the deployment to be accessible from the outside."
execute_command kubectl expose deployment catissimo --type=LoadBalancer --port=8081 --target-port=8080
execute_command kubectl get svc

print_and_wait "And let's verify it"
execute_command "curl `minikube service catissimo --url`"
echo; echo

print_and_wait "Now focus: we are going to deploy the version 2, but without waiting. We're immediately going to perform a regular curl requests to the exposed service we created above."
execute_command --no-wait kubectl apply -f "${DEPLOYMENT_SOURCES}/rolling_updates/v2.deployment.yaml"
echo
execute_command --no-wait kubectl annotate deployment catissimo kubernetes.io/change-cause="upgrade to v2.0"
echo
echo "running curl 10 times (minikube tunnel with service url: `minikube service catissimo --url`)."

for i in {1..10}; do
  curl `minikube service catissimo --url` && echo
  sleep 0.1	# 100 millisec
done
echo

print_and_wait "After a few iterations we should see that we now get the new version of the app deployed."
print_and_wait "The history of deploment contains now more records"
execute_command kubectl rollout history deployment catissimo
print_and_wait "Deployments by default keep track of the previous versions by keeping old replica sets around. In case we roll back, old replica set is applied. We can confirm it here:"
execute_command kubectl get replicasets
print_and_wait "In comparison, one has 0 desired and the other has pods desired and ready"
echo

print_and_wait "Let's demonstrate a depoloyment that failed. In the following example we are using an image that doesn't exist"
execute_command cat "${DEPLOYMENT_SOURCES}/rolling_updates/broken.deployment.yaml"
execute_command kubectl apply -f "${DEPLOYMENT_SOURCES}/rolling_updates/broken.deployment.yaml"
execute_command kubectl rollout status deployment catissimo
print_and_wait "After a short pause we can see that the deployment failed. Checking the pods we can see that.."
execute_command kubectl get pods
print_and_wait "..some pods remain deployed but there was an attempt to deploy new version, which failed. A nice way of seeing the current status is in the 'describe' command output, especially in the 'Replicas' section:"
execute_command kubectl describe deploy catissimo
print_and_wait "The amount of unavailable pods is calculated based on our deployment strategy, the MaxUnavailable parameter specifically. Also notice the changed 'Conditions'."
print_and_wait "The 'get' command let's us inspect the number of running and not running pods also in a clear way:"
execute_command kubectl get replicasets
echo

print_and_wait "The history of deploment now has all 3 deployments:"
execute_command kubectl rollout history deployment catissimo
print_and_wait "Be aware: even though we haven't touched the annotations, our new version of deployment contains the same 'Change cause' annotation as the previous deployment. This can bring confusion if not updated properly."

print_and_wait "If we weren't sure what revision is the current one, deployment has this information which you might've noticed in the 'describe' used a few moments back. Let's get that again:"
execute_command "kubectl describe deploy catissimo | grep -i revision"
execute_command kubectl rollout history deployment catissimo --revision=2
execute_command kubectl rollout history deployment catissimo --revision=3

print_and_wait "This way we are able to inspect the deployment revisions and make an informed decision without guessing."

print_and_wait "Now we would want to roll back the failed deployment. The approach is similar to the rollout history above with slight changes:"
execute_command kubectl rollout undo deployment catissimo --to-revision=2
print_and_wait "Plain 'kubectl rollout undo deployment catissimo' would also work, since it reverts to the previous version when no revision number is entered."
execute_command kubectl get pods
execute_command kubectl rollout history deployment catissimo

print_and_wait "Let's verify the app with a curl command"
execute_command --no-wait "curl `minikube service catissimo --url` && echo; echo"

print_and_wait "On a final note, we are also easily able to restart a deployment. This will cause a new replicaSet creation and therefore a new set of pods."
execute_command kubectl rollout restart deployment catissimo

print_and_wait "Final cleanup (will take some time)."
execute_command kubectl delete all --all
print_and_wait "Let's check if there are pods left, if yes, wait, then continue with CTRL+C"
execute_command kubectl get pods -w
execute_command docker image rm catissimo:1.0
execute_command docker image rm catissimo:2.0

