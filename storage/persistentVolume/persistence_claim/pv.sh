#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../../../cli_utils.sh"
LOCAL_DIR_PATH=/tmp/persistent-storage

print_and_wait -c "Persistent volume created manually and claimed by a pod."

print_and_wait "Since we want to use a local directory, we need to make sure it's created"
execute_command mkdir ${LOCAL_DIR_PATH} 2>/dev/null

print_and_wait "Before we start, make sure you have minikube mount running in the background. Run this in a separate terminal:"
print_and_wait "minikube mount ${LOCAL_DIR_PATH}:${LOCAL_DIR_PATH}"

print_and_wait "Firstly let's create a persistent volume claim manually. Why a PVC first? As you'll see, the ordering doesn't matter:"
cat local.pvclaim.yaml; echo
execute_command kubectl apply -f local.pvclaim.yaml

print_and_wait "Notice that creating a persistent volume (or volume claim) is not reflected in the resources."
execute_command kubectl get all
print_and_wait "...but we can inspect it like this (notice - no PV yet and a pending PVC)"
execute_command kubectl get persistentvolume
execute_command kubectl get persistentvolumeclaim

print_and_wait "We can create a PV now and see that the PVC will pick up the changes"
cat local.persistentvolume.yaml; echo
execute_command kubectl apply -f local.persistentvolume.yaml

print_and_wait "Let's see the resources now (nothing should be empty/pending, otherwise just wait a few moments before proceeding):"
execute_command kubectl get pv
execute_command kubectl get pvc

print_and_wait "Now let's create a pod and check the access to the persistent volume."
cat single.pod.yaml; echo
execute_command kubectl apply -f single.pod.yaml

print_and_wait "We need to wait for the pod to be created (may take some time, continue with CTRL+C)"
execute_command kubectl get pods -w

print_and_wait "Now we should be able to see the information printed into the storage that was mounted through the persistent volume"
execute_command kubectl exec singular-pod -- cat /tmp/data/logs
print_and_wait "And if done correctly, this info should be stored in our local directory ${LOCAL_DIR_PATH}"
execute_command cat ${LOCAL_DIR_PATH}/logs

print_and_wait "We can delete all PVs, PVCs and pods. Be careful, because order matters. Some deletions take substantially more time than others :/"
print_and_wait "Before we start deleting the resources, make sure you CLOSE THE OPENED MINIKUBE MOUNT. Otherwise it will prevent deletion."
rm -rf ${LOCAL_DIR_PATH}
execute_command kubectl delete -f single.pod.yaml --now
kubectl delete pvc --all
kubectl delete pv --all
