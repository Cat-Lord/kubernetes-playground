#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Now let's play with different storage types."

print_and_wait "The most basic type is emptyDir located on a pod."
print_and_wait "Let's create one:"
execute_command cat emptyDir.pod.yaml
execute_command kubectl apply -f emptyDir.pod.yaml

print_and_wait "Before we test it, we need to make sure the pod is deployed and running (continue with CTRL+C)."
execute_command kubectl get pods -w

print_and_wait "Now we execute port-forward to navigate to our web page. Try refreshing the page a couple of times. You can continute with CTRL + C."
execute_command kubectl port-forward pod/emptydir-pod 8080:80

print_and_wait "Now we will create a new pod with hostPath"
execute_command cat hostPath.pod.yaml
execute_command kubectl apply -f hostPath.pod.yaml

print_and_wait "Again, wait until the pod is ready (continue with CTRL+C)."
execute_command kubectl get pods -w

print_and_wait "Now we can execute docker commands that would use the node's docker runtime, because it was mounted into the pod."
execute_command kubectl exec pod/hostpath-pod -- docker ps

print_and_wait "Let's remove the resources to finish this example"
execute_command kubectl delete -f emptyDir.pod.yaml
execute_command kubectl delete -f hostPath.pod.yaml
