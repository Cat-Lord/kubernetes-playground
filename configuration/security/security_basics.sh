#!/bin/bash


print_and_wait -c "Inspecting security in K8s"

print_and_wait "Basic information can be obtained like this"
execute_command kubectl cluster-info

print_and_wait "Now we'll deploy a sample pod just to see some security metadata. We will also create a secret for the pod."
execute_command kubectl create -f not_secure.secret.yaml
execute_command kubectl create -f basic.pod.yaml
execute_command 'kubectl get pods -o yaml | grep -P "serviceAccount(\w+)?: \w+"'

print_and_wait "Service accounts are kubernetes resources, therefore we can inspect them"
execute_command kubectl get serviceAccounts
execute_command kubectl describe serviceAccount default

print_and_wait "By default, newer version of Kubernetes won't generate security token for service accounts automatically (see <none> value for the field 'Tokens' above). We can create one manually."
execute_command cat token.secret.yaml
execute_command kubectl create -f token.secret.yaml

print_and_wait "Now we should be able to see the token assigned:"
execute_command kubectl describe serviceAccount default
print_and_wait "This created secret is a special type of secrets called a token"
execute_command kubectl get secret/default-sa-token
execute_command kubectl describe secret/default-sa-token

print_and_wait "Notice this annotation:"
execute_command "kubectl describe secret/default-sa-token | grep uid | tr -s [:space:]"
print_and_wait "This UID is the ID of the service account this secret is tied to"
execute_command kubectl get sa/default --template={{.metadata.uid}}
echo

print_and_wait "We can see that the secrets are stored inside the pod as certificates here:"
execute_command kubectl exec pod-with-secret -- ls /var/run/secrets/kubernetes.io/serviceaccount
execute_command kubectl exec pod-with-secret -- cat /var/run/secrets/kubernetes.io/serviceaccount/token
echo

print_and_wait "Going back to the default service account..."
kubectl describe sa/default

print_and_wait "...notice the mountable secret. This is a list of secrets that a pod/container using this service account is able to mount"
print_and_wait "If this list is empty, we can mount any secret of the service account."
print_and_wait "The field above that, Image pull secrets, is a list of secrets that are used to pull images from private repositories."
echo

print_and_wait "Now we clean up resources"
execute_command kubectl delete -f basic.pod.yaml
execute_command kubectl delete -f token.secret.yaml
execute_command kubectl delete -f not_secure.secret.yaml
