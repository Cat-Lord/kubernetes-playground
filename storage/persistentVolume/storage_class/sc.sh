#!/bin/bash


print_and_wait -C "Persistent volume through a storage class."
echo

print_and_wait "Storage class doesn't support dynamic provisioning for now. We have to create an alternative deployment:"
execute_command cat local.sc.yaml

print_and_wait "PVC looks similar to the one we'd use in static provisioning:"
execute_command cat local.pvc.yaml

print_and_wait "And the pod stays the same, because it uses PVC which hides the storage details:"
execute_command cat single.pod.yaml

print_and_wait "Let's deploy everything:"
execute_command kubectl create -f local.sc.yaml
execute_command kubectl create -f local.pvc.yaml
execute_command kubectl create -f single.pod.yaml

execute_command kubectl get sc
execute_command kubectl get pvc
execute_command kubectl get pods -w

print_and_wait "Pod details: "
execute_command kubectl describe pods

print_and_wait "We should also have dynamically created PV storage:"
execute_command kubectl get pv

print_and_wait "Final cleanup"
execute_command kubectl delete -f single.pod.yaml
execute_command kubectl delete -f local.pvc.yaml
execute_command kubectl delete -f local.sc.yaml --now
