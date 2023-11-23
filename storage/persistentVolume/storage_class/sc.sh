#!/bin/bash


print_and_wait -c "Persistent volume through a storage class."

print_and_wait "Storage class config:"
execute_command cat local.storageclass.yaml

print_and_wait "PVC looks similar to the one we'd use in static provisioning:"
execute_command cat local.pvclaim.yaml

print_and_wait "And the pod stays the same, because it uses PVC which hides the storage details:"
execute_command cat single.pod.yaml

print_and_wait "Let's deploy everything:"
execute_command kubectl create -f local.storageclass.yaml
execute_command kubectl create -f local.pvclaim.yaml
execute_command kubectl create -f single.pod.yaml

execute_command kubectl get sc
execute_command kubectl get pvc
execute_command kubectl get pods -w

print_and_wait "How about the PV storage?"
execute_command kubectl get pv

print_and_wait "Final cleanup"
execute_command kubectl delete -f single.pod.yaml
execute_command kubectl delete -f local.pvclaim.yaml
execute_command kubectl delete -f local.storageclass.yaml
