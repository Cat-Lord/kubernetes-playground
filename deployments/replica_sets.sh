#!/bin/bash


print_and_wait -C "ReplicaSet bits and pieces"
echo

print_and_wait "For this example we will need to add a few more nodes to our minikube cluster. One extra node should be enough, it won't be added if there are already 2 or more nodes available."
print_and_wait --warn "ATTENTION: YOUR WORK ON THE CLUSTER MIGHT GET LOST (draining of nodes will happen). Make sure to save any progress or create a new environment."
expect_nodes 2

print_and_wait "Let's create a basic deployment with a few replicas"
execute_command kubectl create -f basic.deployment.yaml
execute_command kubectl scale deployment frontend --replicas=5
print_and_wait "Let's wait for the pods to be ready and continue with CTRL+C:"
execute_command kubectl get pods --show-labels -w

RELABELED_POD_NAME=`kubectl get pods -o jsonpath='{.items[].metadata.name}'`
print_and_wait "Purposelly rename pod with the name \"$RELABELED_POD_NAME\" label to not match the deployment selector:"
execute_command kubectl label pod $RELABELED_POD_NAME tier=debugware --overwrite
execute_command kubectl get pods --show-labels

print_and_wait "Notice- re-labeled pod is still up and a new pod was created (look at the age column). We've now got 6 pods."
print_and_wait "We can still access the pods normally, only the deployment/replicaSet wont act on our relabeled pod from now again."
print_and_wait "For that we would need to relabel the pod back to the previous label. Let's see that"
execute_command kubectl label pod $RELABELED_POD_NAME tier=frontend --overwrite
execute_command kubectl get pods --show-labels
print_and_wait "Judging by the age again we have our old pods as before with one pod terminating or already removed (total of 5 pods again)."
echo

print_and_wait "We'll now drain this node and see how it affects the deployment. We'd normally want to simulate failure but it's difficult in the minikube environment, therefore I opted into draining. Essentially, an error would be shown on pods that are running on the failed node and then after a timeout the pods would be rescheduled onto other nodes."
print_and_wait "First list the pods and their nodes:"
execute_command kubectl get pods -o wide
print_and_wait "And now drain the minikube-m02 node..."
execute_command kubectl drain minikube-m02 --ignore-daemonsets
print_and_wait "We may usually need to ignore daemonsets to keep the node connected to the cluster network, DNS and other possible resources provided by the various daemons."
echo
execute_command kubectl get pods -o wide
print_and_wait "All pods were 'moved' to the other available nodes which was in this case the one node left.."
echo

print_and_wait "Final cleanup"
execute_command kubectl delete -f basic.deployment.yaml
execute_command kubectl uncordon minikube-m02
print_and_wait "Don't forget to remove excess nodes with 'minikube node delete <node-name>' :)"
