#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

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

print_and_wait -c "Scheduling, taints, tolerations & more"
echo
print_and_wait "We can assign pods directly to nodes via labels. We need to add a specific label to our node and then create a deployment that utilizes it."
execute_command kubectl label node minikube-m02 preferredPet=cat
print_and_wait "Note that if the node already has the label, output will say that the node was not labeled (but the label will stay there). Let's see that by running the command above again."
execute_command kubectl label node minikube-m02 preferredPet=cat
print_and_wait "With a little bit of formatting magic we can list the labels in a neat way:"

# TODO: this fails even with the execute_command fix, difficult quoting
echo 'kubectl get node minikube-m02 -o jsonpath="{ .metadata.labels }" | tr -d {} | tr , \\n | awk -F":" '\''{ printf "%-30s %-20s\n", $1, $2 }'\'''
kubectl get node minikube-m02 -o jsonpath='{ .metadata.labels }' | tr -d {} | tr , \\n | awk -F: '{ printf "%-30s %-20s\n", $1, $2 }'
echo
print_and_wait "For the rest of this script we will create a deployment and get pods with the '-o wide' option. Make sure to check the 'Node' field."
echo

print_and_wait "This scenario consists of a node selector deployment where we manually define a label in 'nodeSelector' which we require a node to have"
execute_command cat node-selector.deployment.yaml
execute_command kubectl create -f node-selector.deployment.yaml
wait_and_info

print_and_wait "Similar effect can be achieved with node-selector affinity. Let's annotate another node with a selector and see how is the deployement rolled out."
execute_command kubectl delete -f node-selector.deployment.yaml
execute_command kubectl label node minikube-m04 preferredPet=dog
execute_command cat node-affinity.deployment.yaml
execute_command kubectl create -f node-affinity.deployment.yaml
wait_and_info
print_and_wait "We should see that some pods are scheduled on the m02 node and some pods on the m04."

print_and_wait "The constraints above are hard ones - they must be met, otherwise the pod(s) will go into a 'Pending' state. Soft constraints are also available and don't necessarily have to be met."
execute_command kubectl delete -f node-affinity.deployment.yaml
execute_command cat preference-affinity.deployment.yaml
execute_command kubectl create -f preference-affinity.deployment.yaml
wait_and_info
print_and_wait "We should see that most of the pods are scheduled on the m02 node. There can be instances of pods being on the m04 node, since the constraints are soft."
echo

print_and_wait "We can match against more than just a node name. In the following example we are using a pod affinity to run pods on nodes that contain pods with a specified label."
execute_command kubectl delete -f preference-affinity.deployment.yaml
execute_command cat pod-affinity-label.deployment.yaml
execute_command kubectl create -f pod-affinity-label.deployment.yaml
wait_and_info
print_and_wait "Every pod should be deployed to the same node."
echo


print_and_wait "If we would like to force pods to spread out through the cluster we can instead of affinity create an anti-affinity restriction. Below is a simple example that requires the pods to be placed on nodes where there are none of the pods with that label."
execute_command kubectl delete -f pod-affinity-label.deployment.yaml
execute_command kubectl create -f pod-antiaffinity.deployment.yaml
wait_and_info

print_and_wait "Since we've defined the anti-affinity as required, scaling the deployment above the number of nodes will start failing for more pods. Let's see that."
execute_command kubectl scale -f pod-antiaffinity.deployment.yaml --replicas=6
wait_and_info

PENDING_POD_NAME=`kubectl get pods | grep Pending | awk '{print $1}' | head -1`
execute_command "kubectl describe pod $PENDING_POD_NAME | tail -3"
print_and_wait "As we can see, the scaled deployment couldn't schedule two pods since we only have 4 nodes. The describe command gives the info about failed scheduling."

print_and_wait "Finally we'll clean up the cluster and remove the added minikube nodes."
execute_command kubectl delete all --all --now
print_and_wait "Make sure to also manually delete created nodes with 'minikube node delete <node-name>'"
