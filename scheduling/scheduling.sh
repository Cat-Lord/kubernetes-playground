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

print_and_wait -c "Scheduling with affinity"
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
print_and_wait "Also the minikube defaults for node capacity is 110 pods. This is most likely impossible to change and makes the following examples a bit weird. Keep in mind in order demonstrate the scheduling behaviour some samples may seem unnecessary or overly complicated."
print_and_wait "Let's clear the screen and start"

print_and_wait -c "This scenario consists of a node selector deployment where we manually define a label in 'nodeSelector' which we require a node to have"
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
print_and_wait "We should see that most of the pods are scheduled on the m02 node. There can be instances of pods being on the m04 node, since the constraints are soft. K8s determined it's better to break the expectation to make scheduling happen."
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
execute_command cat pod-antiaffinity.deployment.yaml
execute_command kubectl create -f pod-antiaffinity.deployment.yaml
wait_and_info

print_and_wait "Since we've defined the anti-affinity as required, scaling the deployment above the number of nodes will start failing for more pods. Let's see that."
print_and_wait "Some pods will be running and some will stay 'Pending'. We will inspect why right afterwards."
execute_command kubectl scale -f pod-antiaffinity.deployment.yaml --replicas=6
wait_and_info

PENDING_POD_NAME=`kubectl get pods | grep Pending | awk '{print $1}' | head -1`
execute_command "kubectl describe pod $PENDING_POD_NAME | tail -3"
print_and_wait "As we can see, the scaled deployment couldn't schedule two pods since we only have 4 nodes. The describe command gives the info about failed scheduling."
print_and_wait "Let's delete it and proceed to the next example"
execute_command kubectl delete -f pod-antiaffinity.deployment.yaml

print_and_wait "Lastly we'll discuss node cordoning. This prevents scheduling onto a node but doesn't affect already running pods. It's useful for maintenance, rebooting etc."
print_and_wait "We'll cordon multiple nodes and run a deployment that spreads onto all nodes as evenly as possible."
NODE_NAMES=(`kubectl get nodes -o jsonpath='{ .items[*].metadata.name }'`)		# get all node names as array
execute_command kubectl cordon "${NODE_NAMES[1]}"
execute_command kubectl cordon "${NODE_NAMES[2]}"

print_and_wait "The spread deployment has a soft constraint. We left one node available for deployment. Let's create it"
execute_command cat soft-antiaffinity.deployment.yaml
execute_command kubectl create -f soft-antiaffinity.deployment.yaml
wait_and_info
print_and_wait "As we can see, all the pods are scheduled on only one single node. Other nodes are non-schedulable, which we see in the output of the get command."
print_and_wait "If we wanted to evict every running pod from a node, we would use the 'drain' command"
execute_command kubectl drain ${NODE_NAMES[3]} --ignore-daemonsets

print_and_wait "Now let's see where are the pods deployed. You can compare it with previous 'get' command above."
sleep 3
execute_command kubectl get pods -o wide

print_and_wait "Finally we'll clean up the cluster and remove the added minikube nodes. If you plan to continue with other scheduling examples in this directory, you may keep the nodes and continue."
execute_command kubectl uncordon "${NODE_NAMES[1]}"
execute_command kubectl uncordon "${NODE_NAMES[2]}"
execute_command kubectl uncordon "${NODE_NAMES[3]}" 
execute_command kubectl delete all --all --now
print_and_wait "Make sure to also manually delete created nodes with 'minikube node delete <node-name>'"
