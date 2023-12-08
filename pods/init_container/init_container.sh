#!/bin/bash


print_and_wait -C "Playing around with some init containers"
echo

print_and_wait "Firstly, let's see the pod yaml file. Notice the initContainers: we are waiting for a service 'cat-heaven' to be available"
execute_command cat single.pod.yaml
echo

print_and_wait "Since we know that services are automatically added to the DNS, we can deploy a service later and it will satisfy the nslookup above. A simple service:"
execute_command cat basic.service.yaml
echo

print_and_wait "Let's now deploy the pod"
execute_command kubectl create -f single.pod.yaml

print_and_wait "The information about the pod status looks interesting"
execute_command kubectl get pods

print_and_wait "We can access logs of the init container directly. The -c switch expects a container name to access."
execute_command kubectl logs cat-servant -c wait-for-svc-container
echo

print_and_wait "Now let's see what happens when we deploy the service. We will deploy the service and immediatelly go into watch mode to see how the pod behaves. This may take ~10s, after that you can continue with CTRL+C."
execute_command kubectl create -f basic.service.yaml
kubectl get pods -w
echo

print_and_wait "Seeing the logs should now reveal that the service was found and all is good."
execute_command kubectl logs cat-servant -c wait-for-svc-container
echo

print_and_wait "Cleanup time:"
print_and_wait "We can clean all resources by supplying the directory. It's surely risky, so be aware when doing that:"
execute_command kubectl delete -f ./
