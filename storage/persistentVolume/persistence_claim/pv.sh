#!/bin/bash

LOCAL_DIR_PATH=/tmp/persistent-storage

print_and_wait -C "Persistent volume created manually and claimed by a pod."

print_and_wait "Since we want to use a local directory, we need to make sure it's created."
execute_command "rm -r ${LOCAL_DIR_PATH} 2>/dev/null; mkdir ${LOCAL_DIR_PATH} 2>/dev/null"

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

print_and_wait "Bind information is also reflected on the PVC:"
execute_command 'kubectl describe pvc | grep -i "used by"'

print_and_wait "The PV has read/write once permissions. Let's try creating another pod that uses it to make sure it has access to the PV. The pod will be a copy of the existing one:"
execute_command cat copy.pod.yaml
execute_command kubectl create -f copy.pod.yaml

print_and_wait "Wait until it's created and continue with CTRL+C"
execute_command kubectl get pods -w
execute_command kubectl exec singular-pod-copy -- cat /tmp/data/logs

print_and_wait "Since the reclaim policy is set to retain in our PV, we can do this:"
execute_command kubectl delete -f single.pod.yaml --now
execute_command kubectl delete -f copy.pod.yaml --now
print_and_wait "The PV and PVC still stay... "
execute_command kubectl get pvc
execute_command 'kubectl describe pvc | grep -i "used by"'
execute_command kubectl get pv
print_and_wait "...and so does the RETAINed storage, even though there are no pods that are using it."
execute_command cat ${LOCAL_DIR_PATH}/logs

print_and_wait "Deleting the PVC gets the PV into an interesting situation"
execute_command kubectl delete pvc --all
execute_command kubectl get pv
print_and_wait "Status Released evokes that the PV is not claimed by any PVC and the storage is stil there."
execute_command cat ${LOCAL_DIR_PATH}/logs

print_and_wait "If we wanted to reuse that PV, we would need to do it a little differently, because it's not possible the expected way."
execute_command kubectl create -f local.pvclaim.yaml
execute_command kubectl create -f single.pod.yaml
execute_command kubectl get pods
execute_command kubectl get pv
print_and_wait "PV still released and the pod will stay pending because the storage is not reusable after it has been 'dropped' by the PVC. We'd have to recreate all the resources to reassign it back."
echo

print_and_wait "Finally we delete all the resources. Be careful, because order matters: Pods first, then PVCs and finally PVs. Otherwise you might get stuck in a waiting state."
execute_command rm -r ${LOCAL_DIR_PATH}
execute_command kubectl delete -f single.pod.yaml
execute_command kubectl delete -f local.pvclaim.yaml
execute_command kubectl delete pv --all

print_and_wait --no-wait "Don't forget to close the minikube mount ;)"
