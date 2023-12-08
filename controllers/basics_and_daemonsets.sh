#!/bin/bash


expect_nodes 4

print_and_wait -C "Controllers basics overview"
echo

print_and_wait "We can inspect all the different controllers querying the kube-system namespace"
execute_command kubectl get --namespace kube-system all

print_and_wait "Inspecting a single resource and its state"
execute_command kubectl get --namespace kube-system deployment coredns
execute_command kubectl get --namespace kube-system daemonsets

print_and_wait "Notice the number of desired/current daemonsets above. Why? Because we have..."
execute_command kubectl get nodes
print_and_wait "...`kubectl get --no-headers nodes | wc -l` nodes!"

print_and_wait "Now we create a basic daemonset first for all nodes and then for a subset of nodes."
execute_command cat basic.daemonset.yaml
execute_command kubectl create -f basic.daemonset.yaml --save-config
print_and_wait "Now we can get information about deployed daemon set the same way as with other resources"
execute_command kubectl get ds basic-ds -o wide
print_and_wait "Or with describe"
execute_command kubectl describe ds basic-ds
print_and_wait "Assignment to pods can be seen from the pod perspective"
execute_command kubectl get pods -o wide
print_and_wait "Listing labels of the deployed pods we can see that there are additional labels that help K8s determine if the daemon set pod is the newest version etc."
execute_command kubectl get pods --show-labels
echo
print_and_wait "With slight changeas to the yaml, we will now deploy an updated version of the daemon set to sett how it rolls out new pods. We will then immediatelly show the rollout status to watch it in real-time."
execute_command cat basic-v2.daemonset.yaml
execute_command kubectl apply -f basic-v2.daemonset.yaml

print_and_wait --no-wait '...This might take some time'
execute_command --no-wait kubectl rollout status daemonsets basic-ds
print_and_wait "The describe command shows us the replacement of pods in the 'Events' section:"
execute_command kubectl describe ds basic-ds
echo

print_and_wait "It's time to create a daemonset but with node selection in place. Let's remove the previous one and create the new one which has a nodeSelector condition."
execute_command kubectl delete -f basic-v2.daemonset.yaml
execute_command cat node-selected.daemonset.yaml
execute_command kubectl create -f node-selected.daemonset.yaml
execute_command kubectl get ds
print_and_wait "Oh... no pods are deployed. You might be able to guess why."
execute_command kubectl get nodes --show-labels
print_and_wait "We relied on a label that's not actually on any node. We can either change the label in deamon set manifest or add a label to our node."
execute_command kubectl label node minikube-m02 type=important-ds

print_and_wait "Now it should be working as expected"
execute_command kubectl get pods -o wide

print_and_wait "Removing that label will cause the pod to be terminated"
execute_command kubectl label node minikube-m02 type-
execute_command kubectl get pods


print_and_wait "Clean up"
execute_command kubectl delete -f node-selected.daemonset.yaml
print_and_wait "Don't forget to delete any extra nodes created for this example."
