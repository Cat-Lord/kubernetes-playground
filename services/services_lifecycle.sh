#!/bin/bash


print_and_wait -c "Let's first deploy a sample application"
print_and_wait "Application configuration:"
cat nginx.deployment.yaml; echo

execute_command kubectl apply -f nginx.deployment.yaml

print_and_wait "We can use port-forwarding to access the deployment. Navigate to localhost:8080 for verification or continue with CTRL+C."
execute_command kubectl port-forward deployment/app-deployment 8080:80

print_and_wait "Did you notice a subtle detail in the command above? We are able to port-forward not only directly to pods, but also deployments (and services)!"

print_and_wait "We can expose services using a simple 'expose' command without an actual service yaml definition. We can define ports, type and other properties. Let's see it in action below."
execute_command kubectl expose deployment app-deployment --port 80 --target-port 8080 --type ClusterIP
execute_command kubectl get svc
print_and_wait "Let's delete the service, clear the screen and continue."

execute_command kubectl delete svc app-deployment
print_and_wait "...press anything to continue"

print_and_wait -c "Let's get information about deployed pods and see how we can use services to access them."

echo 'kubectl get pods -o name --no-headers=true | head -n 1'
POD_1_NAME=`kubectl get pods -o name --no-headers=true | head -n 1`	# e.g. pod/app-deployment-748f7fd48f-2sknn
POD_1_IP=`kubectl get ${POD_1_NAME} --template '{{.status.podIP}}'`

echo "Pod 1: ${POD_1_NAME} | ${POD_1_IP}"
echo; # spacing

print_and_wait "To access pods we can call an exposed service."
print_and_wait "First we spin up a load-balancer service (wait until it's created and continue with CTRL+C)"
execute_command cat loadbalancer.service.yaml
execute_command kubectl apply -f loadbalancer.service.yaml

print_and_wait "MAKE SURE the minikube tunnel is running, otherwise you might wait for just an eternity :)"
execute_command kubectl get svc -w

print_and_wait "Now let's use the name of the service instead of direct IP address"
echo "kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1"
kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1; echo
SERVICE_DNS_NAME=`kubectl get services --no-headers -o custom-columns=":metadata.name" | head -1`
execute_command kubectl exec ${POD_1_NAME} -- curl -s http://${SERVICE_DNS_NAME}:8080

print_and_wait "Let's try a nodePort service (wait until it gets created and continue with CTRL+C)"
execute_command cat nodeport.service.yaml
execute_command kubectl apply -f nodeport.service.yaml
execute_command kubectl get svc -w

print_and_wait "We actually need to remove our load-balancer to be able to access pods via the nodePort service."
execute_command kubectl delete service app-balancer

print_and_wait "You can now see that we can access the proxied port. If a browser doesn't open, simply navigate to localhost:30123."
execute_command sensible-browser http://localhost:30123

print_and_wait "And finally clean up resources"
execute_command kubectl delete all -l app=meowness
