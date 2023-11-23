#!/bin/bash


print_and_wait -c "Internal DNS"

print_and_wait "DNS is cluster-wide and set up in the kube-system namespace. We need to keep the namespace in mind, otherwise we won't be able to get information about the DNS."
execute_command kubectl get service --namespace kube-system

print_and_wait "Couple of key points here. We can notice that we are mounting a config volume with a Corefile. This Corefile contains the DNS configuration and is mounted to /etc/coredns folder."

print_and_wait "We can get the coredns ConfigMap easily:"
execute_command kubectl describe cm coredns -n kube-system

print_and_wait "It's possible to override the coredns service by just simply deploying a new configuration. Let's first back up the current configuration:"
echo 'kubectl get cm -n kube-system coredns -o yaml > coredns-v1.configmap.yaml'
kubectl get cm -n kube-system coredns -o yaml > coredns-v1.configmap.yaml

print_and_wait "..and deploy a new one"
execute_command cat coredns-v2.configmap.yaml
execute_command kubectl replace -f coredns-v2.configmap.yaml

print_and_wait "Update doesn't happen immediately, it usually takes a few minutes. We can inspect any errors or refreshes of the configuration by tailing the logs:"
execute_command kubectl logs -n kube-system --selector 'k8s-app=kube-dns'		# we could use a --follow option but it's bugged with CTRL+C (doesn't continue this script properly)

SERVICE_IP=$(kubectl get svc -n kube-system kube-dns -o jsonpath='{ .spec.clusterIP }')
print_and_wait "First we need to deploy sample pods to be able to simulate DNS lookups"
execute_command kubectl create -f basic.pod.yaml

print_and_wait "Now with the cluster-ip of the dns service we can perform nslookup queries to verify it's working correctly."
execute_command kubectl get svc -n kube-system kube-dns
execute_command kubectl exec basic-pod -- nslookup www.github.com $SERVICE_IP
execute_command kubectl exec basic-pod -- nslookup www.cats.com $SERVICE_IP

print_and_wait "Let's revert the DNS configuration back to the initial one."
execute_command kubectl delete -f coredns-v2.configmap.yaml
execute_command kubectl create -f coredns-v1.configmap.yaml

print_and_wait "Next we will deploy a pod with altered DNS settings."
execute_command cat dnsconfiged.pod.yaml
execute_command kubectl create -f dnsconfiged.pod.yaml

print_and_wait "To verify the DNS configuration we can print out contents of the /etc/resolv.conf file and we should see our nameservers configuration."
execute_command kubectl exec configured-pod -- cat /etc/resolv.conf

print_and_wait "IP addresses get dots replaced with dashes in DNS. Let's take a look at how we can use this to target pods."
print_and_wait "We need to store the IP and translate the dots"
# TODO: piping doesnt work in execute_command
echo 'kubectl get pod basic-pod -o jsonpath='{ .status.podIPs[0].ip }' | tr . -'
kubectl get pod basic-pod -o jsonpath='{ .status.podIPs[0].ip }' | tr . - && echo
POD_IP=`kubectl get pod basic-pod -o jsonpath='{ .status.podIPs[0].ip }' | tr . -`

print_and_wait "Now we can execute an nslookup using this dashed IP address to verify it."
execute_command kubectl exec configured-pod -- nslookup ${POD_IP}.default.pod.cluster.local $SERVICE_IP

echo
print_and_wait "Final cleanup"
execute_command kubectl delete -f basic.pod.yaml --now
execute_command kubectl delete -f dnsconfiged.pod.yaml --now
