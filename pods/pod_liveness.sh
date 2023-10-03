#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Liveness checks with HTTP and exec approach"

print_and_wait "First we create a pod with HTTP liveness probe"
execute_command kubectl apply -f http-liveness-nginx.pod.yaml

print_and_wait "Pod definition Yaml file:"
cat http-liveness-nginx.pod.yaml;echo

print_and_wait "Now we will manually remove the nginx 'index.html' file to cause a failure (this will take a short moment)."
execute_command kubectl exec http-liveness-nginx -- rm /usr/share/nginx/html/index.html
sleep 5

print_and_wait "Now we inspect the latest event for this pod to verify the restart:"
execute_command kubectl get event --field-selector involvedObject.name=http-liveness-nginx

print_and_wait "Next let's create a self-restarting pod with the exec liveness probe. First, look at the definition file:"
cat exec-liveness-nginx.pod.yaml;echo
print_and_wait "...and now we create it and wait for the restart (will take only couple of seconds)"
execute_command kubectl apply -f exec-liveness-nginx.pod.yaml
sleep 5

print_and_wait "Now let's see if the exec pod restarted as expected:"
execute_command kubectl get event --field-selector involvedObject.name=exec-liveness-nginx

print_and_wait "And finally we remove the pods"
execute_command kubectl delete -f http-liveness-nginx.pod.yaml
execute_command kubectl delete -f exec-liveness-nginx.pod.yaml --now 	# don't wait, delete immediately
