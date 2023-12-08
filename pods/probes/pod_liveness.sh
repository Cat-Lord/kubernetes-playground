#!/bin/bash


print_and_wait -C "Liveness checks with HTTP and exec approach"
echo

print_and_wait "First we create a pod with HTTP liveness probe"
execute_command kubectl apply -f http-liveness-nginx.pod.yaml

print_and_wait "Pod definition Yaml file:"
execute_command cat http-liveness-nginx.pod.yaml
echo

print_and_wait "Now we will manually remove the nginx 'index.html' file to cause a failure (this will take a short moment)."
execute_command kubectl exec http-liveness-nginx -- rm /usr/share/nginx/html/index.html
execute_command sleep 2

print_and_wait "Now we inspect the latest event for this pod to verify the restart:"
execute_command kubectl get event --field-selector involvedObject.name=http-liveness-nginx

print_and_wait "Next let's create a self-restarting pod with the exec liveness probe. First, look at the definition file:"
execute_command cat exec-liveness-nginx.pod.yaml
echo

print_and_wait "...and now we create it and wait for the restart. After ~30 seconds we should see that the pod is restarted based on the number in the restart column. Continue with CTRL+C."
execute_command kubectl apply -f exec-liveness-nginx.pod.yaml
execute_command kubectl get pods exec-liveness-nginx -w
print_and_wait "Let's also see the events:"
execute_command kubectl get event --field-selector involvedObject.name=exec-liveness-nginx

print_and_wait "Now a more real-life example: We have a Spring app that takes 5 seconds to start. We will first create an image:"
execute_command docker build -t spring-liveness spring-liveness
print_and_wait "No we will use this image in a deployment with a HTTP probe just like we just did above"
execute_command cat spring.pod.yaml
print_and_wait "We will deploy this pod and notice that the initial delay is few seconds. This is enough for a few probe failures to occur, but the pod will be running correctly after some time."
execute_command kubectl create -f spring.pod.yaml
execute_command --no-wait kubectl describe pod/spring
execute_command --no-wait sleep 5
execute_command --no-wait kubectl describe pod/spring

print_and_wait "As we can see there are a few failures but the pod is now up. We can verify it by running a curl command from a node."
execute_command "minikube ssh -n minikube curl $(kubectl get pod/spring -o jsonpath='{.status.podIP}'):8080/actuator/health && echo"

print_and_wait "Finally, we'll remove the pods"
execute_command kubectl delete -f spring.pod.yaml
execute_command kubectl delete -f http-liveness-nginx.pod.yaml
execute_command kubectl delete -f exec-liveness-nginx.pod.yaml --now 	# don't wait, delete immediately
