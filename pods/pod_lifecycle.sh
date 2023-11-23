#!/bin/bash


print_and_wait -c "Pod sample where we create and delete a pod. Press any key to start"

echo "List of all pods"
execute_command kubectl get pods

print_and_wait "Now let's create a sample pod"
execute_command kubectl run my-nginx --image=nginx:alpine

print_and_wait "Let's now see the details of the newly created pod"
execute_command kubectl describe pod my-nginx

print_and_wait "Now we forward a port to be able to access the pod from outside. You can check it by accessing localhost:8080 or continue by pressing CTRL+C to kill the port-forwarding process.."
execute_command kubectl port-forward my-nginx 8080:80

print_and_wait "Finally, let's delete the pod"
execute_command kubectl delete pod my-nginx

print_and_wait "...and verify it"
execute_command kubectl describe pod my-nginx
