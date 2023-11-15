#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../../cli_utils.sh"

print_and_wait "For this example we will need to add a few more nodes to our minikube cluster. We will need control plane and 3 additional nodes. Run the following command manually and verfiy with 'minikube node list':"
print_and_wait "minikube node add"
NODE_COUNT=`minikube node list | wc -l`

if [[ -z "$NODE_COUNT" || "$NODE_COUNT" != 4 ]]; then
  echo "Error: Insufficient number of cluster nodes (found $NODE_COUNT nodes). Run 'minikube node add' and make sure to create exactly 4 nodes."
  exit 1
fi

function wait_and_info() {
  print_and_wait "Wait for the pods to get created and continue with CTRL+C"
  execute_command kubectl get pods -w
  execute_command kubectl get pods -o wide
  echo
}

print_and_wait -c "Scheduling with taints & tolerations"
echo
print_and_wait "Taints let us control scheduling from the node's perspective. Tolerations make the taint ignored under certain conditions."
print_and_wait "Our deployment will try to spread onto all available nodes."
execute_command cat spread.deployment.yaml
execute_command kubectl create -f spread.deployment.yaml
wait_and_info

print_and_wait "Now let's remove the deployment and create a taint on one of the nodes"
execute_command kubectl delete -f spread.deployment.yaml
TAINTED_NODE_NAME=`kubectl get nodes -o jsonpath='{ .items[].metadata.name }'`
print_and_wait "We will apply the taint to the node \"$TAINTED_NODE_NAME\"."
execute_command kubectl taint node minikube kei=NotThisNode:NoSchedule 						# 'kei' is purposely typed with a typo (key) to indicate that it is an arbitrary string

print_and_wait "Taints are reflected in the node properties in the describe command:"
execute_command "kubectl describe node minikube | grep -i taints"
print_and_wait "Let's try to do the previous deployment and see if our taint was applied"
execute_command kubectl create -f spread.deployment.yaml
wait_and_info
print_and_wait "As we can see, no pods were scheduled onto the \"$TAINTED_NODE_NAME\" node because of the taint."

print_and_wait "We can bypass taints with tolerations. They practically make specific taints invisible and scheduling is performed as there was no toleration at all. Let's see the following deployment:"
execute_command kubectl delete -f spread.deployment.yaml
execute_command cat toleration.deployment.yaml
execute_command kubectl create -f toleration.deployment.yaml
wait_and_info

print_and_wait "We see that pods are scheduled onto each node just as if the taint on node \"$TAINTED_NODE_NAME\" wasn't there. This is only the case because the deployement had a toleration for each of the pods." 

print_and_wait "Clean up & removing taints (notice hyphen at the end)"
execute_command kubectl delete -f toleration.deployment.yaml
execute_command kubectl taint node minikube kei=NotThisNode:NoSchedule-
print_and_wait "Don't forget to remove the additional nodes with 'minikube node delete <node-name>' in case you don't want to try other scheduling examples :)"
