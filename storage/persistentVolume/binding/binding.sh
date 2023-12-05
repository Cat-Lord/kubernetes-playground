#!/bin/bash

LOCAL_DIR_PATH=/tmp/persistent-storage

print_and_wait -C "PV <=> PVC binding process"
print_and_wait "- Static provisioning -"
echo

print_and_wait "We will play around with different PV and PVC properties and see how binding takes place."
print_and_wait "We need to make sure the minikube addon 'default-storageclass' is disabled, otherwise minikube creates the PVs automatically for us which makes this example confusing"
minikube addons disable default-storageclass
echo
echo

# print a file, create the resource and then
# check the resource being created
function cat_create_check(){
  FILENAME=$1
  print_and_wait "Creating resource $FILENAME"
  execute_command cat "$FILENAME"
  execute_command kubectl create -f "$FILENAME"
  print_and_wait "Let's see how the creation affected status of existing PVs and PVCs:"
  execute_command kubectl get pv
  execute_command kubectl get pvc
  echo
}

print_and_wait "The most important part for all the following yaml files will be storage size and access mode, make sure to check them."
print_and_wait "Let's deploy all the PVs first, since they show their stats better. After that we will deploy PVCs one by one and analyze why they are bound/not bound."
echo
execute_command cat small.pv.yaml
execute_command kubectl create -f small.pv.yaml

execute_command cat big.pv.yaml
execute_command kubectl create -f big.pv.yaml

print_and_wait "Now let's deploy PVCs one by one."
cat_create_check small.pvc.yaml
print_and_wait "Now we have the PVC unbound (Pending) because it doesn't meet any access modes of the deployed PVs even though there is plenty of available storage."
echo

cat_create_check big.pvc.yaml
print_and_wait "In this case we have requested too much storage so the PVC stays Pending until we delete it or create an appropriate PV."

cat_create_check storageclass.pvc.yaml
print_and_wait "PVCs don't require a storageclass by default. If we specify one, only PVs with that storageclass name can be bound to it. Leaving the storageClassName attribute empty behaves as if there was no storageclass name provided."

cat_create_check fit-1.pvc.yaml
print_and_wait "Now we see the first bind - we have matched exactly the amount of provided storage for one of the PVs."

cat_create_check fit-2.pvc.yaml
print_and_wait "Another bind. This time we are wasting a bit of space because there is a leftover storage."

print_and_wait "Cleaning up"
execute_command "kubectl delete -f ./"
