#!/bin/bash


print_and_wait -C "Services & the cluster DNS"

execute_command kubectl create -f nginx.deployment.yaml

execute_command kubectl expose deploy app-deployment --port 80 --target-port 8080

print_and_wait "We've created a deployment, exposed it and now we will look at the DNS server:"
execute_command kubectl get svc kube-dns --namespace kube-system
DNS_SERVER_IP=`kubectl get svc kube-dns --namespace kube-system -o jsonpath='{ .spec.clusterIP }'`

print_and_wait "With the DNS IP address we can use nslookup to query the available endpoints." 
POD_NAME=`kubectl get pods -o jsonpath='{ .items[0].metadata.name }'`
execute_command kubectl exec ${POD_NAME} -- nslookup app-deployment.default.svc.cluster.local ${DNS_SERVER_IP}

print_and_wait "We can also inspect env variables:"
execute_command "kubectl exec ${POD_NAME} -- env | sort"
print_and_wait "You might notice that we don't see the service above. This is because we first created the deployment and the service got created afterwards. Let's revert it and create the service first."

execute_command kubectl delete -f nginx.deployment.yaml
execute_command kubectl delete svc app-deployment
execute_command kubectl create -f loadbalancer.service.yaml
execute_command kubectl create -f nginx.deployment.yaml

print_and_wait "Let's see now..."
POD_NAME=`kubectl get pods -o jsonpath='{ .items[0].metadata.name }'`
execute_command 'kubectl exec ${POD_NAME} -- env | sort'
print_and_wait "The service metadata get inserted into the pod as environment variables, yay!"
echo

print_and_wait "And finally let's create an externalName service."
execute_command cat external.service.yaml
execute_command kubectl create -f external.service.yaml

# TODO: Strangely, the command below fails repeatedly in this script but it always succeedes outside of the script. Not sure why, quotation doesn't solve it.
print_and_wait "Now we can take a look at how the DNS resolves when queried from a pod. Please be aware that if the following command fails, it might be because the service was not yet fully set up. Try again a few seconds later from other terminal."
execute_command "kubectl exec ${POD_NAME} -- nslookup external-svc.default.svc.cluster.local ${DNS_SERVER_IP}"
print_and_wait "We see that the service name got translated into the respective external name present in the config file."
echo

print_and_wait "In the end clean up the resources"
execute_command kubectl delete all -l app=meowness
