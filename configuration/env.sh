#!/bin/bash

SAMPLES_DIR="./env_variables"

print_and_wait -c "Environment variables & Pods"

print_and_wait "Even though we can define variables in a Dockerfile or even application properties, it's better to abstract this information away from the source code."
print_and_wait "The reason may be security, portability, etc."
echo

print_and_wait "First simple example are plain env variables in a container image."
execute_command cat ${SAMPLES_DIR}/basic.deployment.yaml
execute_command kubectl create -f ${SAMPLES_DIR}/basic.deployment.yaml
print_and_wait "Wait and continue with CTRL+C"
execute_command kubectl get pods -w

POD_NAME=`kubectl get pods -o jsonpath='{ .items[].metadata.name }'`
execute_command 'kubectl exec $POD_NAME -- /bin/sh -c "env | sort" | grep THY_'

print_and_wait "Environment variables are set on creation and never updated. Updating variables is only possible by recreating the pods. Let's create a service and see that environment variables about the service are not available until we recreate the pod."
execute_command kubectl expose deployment whisker --port 80
execute_command kubectl exec $POD_NAME -- /bin/sh -c "env | sort"

print_and_wait "No service-related env variables above. Deleting the pod from the deployment causes the replicaSet to step in and recreate it:"
execute_command kubectl delete pods --all --now
print_and_wait "Let's watch them get recreated (continue with CTRL+C):"
execute_command kubectl get pods -w

POD_NAME=`kubectl get pods -o jsonpath='{ .items[].metadata.name }'`
execute_command kubectl exec $POD_NAME -- /bin/sh -c "env | sort"

print_and_wait "Service exposing the deployment got created after the deployment. Recreating the pod now shows that it got populated with env variables with details about that service (e.g. WHISKER_PORT... and WHISKER_SERVICE...). As we've seen this was not done automatically."

print_and_wait "To do this automatically we would need to mount environment variables as volumes. Let's do that now."
print_and_wait "We can create the config map using the API this time utilizing an env file."
execute_command cat ${SAMPLES_DIR}/env_file_config
execute_command kubectl create configmap file-env --from-file=${SAMPLES_DIR}/env_file_config

print_and_wait "And now create the deployment which will mount the env above"
execute_command cat ${SAMPLES_DIR}/volumed.deployment.yaml
execute_command kubectl create -f ${SAMPLES_DIR}/volumed.deployment.yaml

print_and_wait "Testing if the volume was mounted properly:"
POD_NAME=`kubectl get pods -o jsonpath='{ .items[].metadata.name }'`
execute_command kubectl exec $POD_NAME -- cat /etc/appconfig/env_file_config

print_and_wait "Let's update the configmap and see if anything changed for the pod. Keep in mind that the command below will replace all the variables in the configmap."
execute_command "kubectl patch cm file-env -p '{\"data\": { \"env_file_config\": \"kitten=purrs\" } }'"
execute_command sleep 5
execute_command kubectl get cm file-env -o yaml
execute_command kubectl exec $POD_NAME -- cat /etc/appconfig/env_file_config

print_and_wait "As we can see the env file got updated without our intervention with the pods or deployment. There is a chance you're still seeing the previous values. This is caused by the API server not refreshing the volume data yes - just wait a few seconds and try again."
print_and_wait "We can update our configmap (or other resources) directly with the edit option. This will open a text editor. If we quit, no changes will be applied."
execute_command kubectl edit cm file-env

print_and_wait "Cleanup"
execute_command kubectl delete -f ${SAMPLES_DIR}/basic.deployment.yaml
execute_command kubectl delete -f ${SAMPLES_DIR}/volumed.deployment.yaml
execute_command kubectl delete cm --all --now

