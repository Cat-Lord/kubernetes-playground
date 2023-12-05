#!/bin/bash


print_and_wait -C "Now let's play with different storage types."

print_and_wait "The most basic type is emptyDir located on a pod."
print_and_wait "Let's create one:"
execute_command cat emptyDir.deployment.yaml
execute_command kubectl apply -f emptyDir.deployment.yaml

print_and_wait "Before we test it, we need to make sure the pod is deployed and running (continue with CTRL+C)."
execute_command kubectl get pods -w

POD_NAME=`kubectl get pods --no-headers | tr -s ' ' | cut -d" " -f1`
print_and_wait "Empty directory can be accessed to see the data..."
execute_command kubectl exec $POD_NAME -- cat /usr/share/nginx/html/index.html
print_and_wait "And when simulating a pod crash..."
execute_command kubectl exec $POD_NAME -c paw -- kill 1
execute_command kubectl exec $POD_NAME -c html-updater -- kill 1
print_and_wait "Wait for K8s to recreate the pods and continue with CTRL+C."
execute_command kubectl get pods -w
echo
execute_command kubectl exec $POD_NAME -- cat /usr/share/nginx/html/index.html
print_and_wait "...we still see the old data. This doesn't work when a pod gets deleted:"
execute_command kubectl delete pod $POD_NAME
POD_NAME=`kubectl get pods --no-headers | tr -s ' ' | cut -d" " -f1`
print_and_wait "Wait for the pods to be accessible and continue with CTRL+C"
execute_command kubectl get pods -w
execute_command kubectl exec $POD_NAME -- cat /usr/share/nginx/html/index.html
print_and_wait "Dont' be fooled by the output above - it might look like the data is still there, but notice the time and messages."
echo

print_and_wait "Now we will create a new pod with hostPath"
execute_command cat hostPath.pod.yaml
execute_command kubectl apply -f hostPath.pod.yaml

print_and_wait "Again, wait until the pod is ready (continue with CTRL+C)."
execute_command kubectl get pods -w

print_and_wait "Now we can execute docker commands that would use the node's docker runtime, because it was mounted into the pod."
execute_command kubectl exec pod/hostpath-pod -- docker ps

print_and_wait "Let's remove the resources to finish this example"
execute_command kubectl delete -f emptyDir.deployment.yaml
execute_command kubectl delete -f hostPath.pod.yaml
