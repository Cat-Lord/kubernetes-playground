#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"
SOURCE_DIR="./local_dynamic_provisioning"
print_and_wait -c "Storage Class with local provisioner"
echo

print_and_wait "Local provisioners currently (November 2023) don't support dynamic provisioning. We will instead install a dynamic local provisioner provided by Rancher on Github."
print_and_wait "Check the repository: https://github.com/rancher/local-path-provisioner"
execute_command kubectl apply -f $SOURCE_DIR/local.provisioner.yaml
print_and_wait "Wait until provisioner pod is deployed and continue with CTRL+C."
execute_command kubectl get -n local-path-storage pods -w

print_and_wait "We should now see a pod deployed for a local provisioner:"
execute_command kubectl -n local-path-storage get pod

print_and_wait "And also inspect its logs"
execute_command kubectl -n local-path-storage logs -l app=local-path-provisioner

print_and_wait "Let's now create a PVC"
execute_command cat $SOURCE_DIR/local.pvc.yaml
execute_command kubectl create -f $SOURCE_DIR/local.pvc.yaml

print_and_wait "And finally create a pod that uses the PVC"
execute_command cat $SOURCE_DIR/local.pod.yaml
execute_command kubectl create -f $SOURCE_DIR/local.pod.yaml
print_and_wait "Wait until all resources are deployed and continue with CTRL+C."
execute_command kubectl get pods -w

print_and_wait "Data mounted locally on the pod:"
execute_command kubectl exec volume-test -- cat /data/meow
echo

print_and_wait "If we wanted to print out the data writen onto the PV, we need to..."
print_and_wait "...find out what node is the PV created on:"
execute_command 'kubectl describe pv | grep selected-node | awk -F " " '\''{print $NF}'\'''
NODE_NAME=`kubectl describe pv | grep selected-node | awk -F " " '{print $NF}'`

print_and_wait "...and with the help of minikube we can issue an SSH command directly onto the node where our PV is mounted:"
execute_command "minikube ssh -n $NODE_NAME cat /opt/local-path-provisioner/*/meow"

print_and_wait "Now based on our config we will delete the pod and the PVC and expect the designated storage to be deleted (might take a while)."
execute_command kubectl delete -f $SOURCE_DIR/local.pod.yaml --now
execute_command kubectl delete -f $SOURCE_DIR/local.pvc.yaml --now
print_and_wait "And now test the node storage deletion"
execute_command "minikube ssh -n $NODE_NAME cat /opt/local-path-provisioner/*/meow"
execute_command "minikube ssh -n $NODE_NAME ls /opt/local-path-provisioner"
print_and_wait "The PV got deleted and the directory still remains. Recreating the PVC and pod would create a new directory."

print_and_wait "Cleanup"
execute_command kubectl delete -f $SOURCE_DIR/local.provisioner.yaml --now
