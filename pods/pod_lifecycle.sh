#!/bin/bash

print_and_wait -C "Pod basics using API & yaml"
echo

print_and_wait "There are pods that are deployed to provide Kubernetes-related services. These are normally not visible under the default namespace. We can get pods (and other resources) from all namespaces with a simple option:"
execute_command kubectl get pods --all-namespaces

print_and_wait "Now let's create a sample pod"
execute_command kubectl run my-nginx --image=nginx:alpine

print_and_wait "We can view existing pods like this:"
execute_command kubectl get pods

print_and_wait "Let's now see the details of the newly created pod"
execute_command kubectl describe pod my-nginx

print_and_wait "Now we forward a port to be able to access the pod from outside. You can check it by accessing localhost:8080 or continue by pressing CTRL+C to kill the port-forwarding process.."
execute_command "kubectl port-forward my-nginx 8080:80 > /dev/null &"
execute_command curl http://localhost:8080
print_and_wait "Let's close the port-forwarding process and continue"
# neat way of killing the most recent job
execute_command "kill %%"

print_and_wait "Finally, let's delete the pod"
execute_command kubectl delete pod my-nginx

print_and_wait "We can also delete pod by name. Let's recreate it and do it that way."
execute_command kubectl run my-nginx --image=nginx:alpine
execute_command kubectl delete pod/my-nginx

print_and_wait "Here we create a pod using a YAML definition instead of manually issuing commands."
execute_command cat nginx.pod.yaml
execute_command kubectl create -f nginx.pod.yaml --save-config

print_and_wait "The --save-config option above let's us use the 'apply' to update the pod later. Let's do that by adding a few labels:"
execute_command cat nginx-v2.pod.yaml
execute_command kubectl apply -f nginx-v2.pod.yaml

print_and_wait "...and verify"
execute_command kubectl get pods --show-labels

print_and_wait "Now we will delete the created pod using the same approach."
execute_command kubectl delete -f nginx-v2.pod.yaml

print_and_wait "We can have multiple containers inside a single pod:"
execute_command cat multi.pod.yaml
execute_command kubectl create -f multi.pod.yaml
print_and_wait "Wait for the pod to be ready and continue with CTRL+C"
execute_command kubectl get pods -w
print_and_wait "As we can see, even though we have deployed multiple containers, only one pod was created for them (based on our configuration)"
execute_command kubectl delete -f multi.pod.yaml --now

print_and_wait "We can check existing pods."
execute_command kubectl get pods
print_and_wait "Be careful about the active namespace, e.g. kube-system has pods which are not visible by default:"
execute_command kubectl get pods -n kube-system
