#!/bin/bash


print_and_wait -c "Working with ConfigMaps"

print_and_wait "A simple config map is a normal K8s resource"
cat simple.configmap.yaml; echo

print_and_wait "Created as any resource:"
execute_command kubectl create -f simple.configmap.yaml

print_and_wait "A more flexible approach is to create a config map using a configuration file"
execute_command kubectl create configmap userconfig --from-env-file="user.conf"

print_and_wait "We are also able to provide the key-value pairs directly via CLI"
execute_command kubectl create configmap "userconfig-cli" --from-literal=appName=my-app --from-literal=myappversion=1.0.1

print_and_wait "As with other resources, we can get a list of config maps"
execute_command kubectl get configmaps

print_and_wait "We can also see details about the config map"
execute_command kubectl get configmap userconfig-cli -o=yaml

print_and_wait "Let's now take a look at how we can utilize config maps in a different way when creating a pod."
execute_command cat basic.pod.yaml
execute_command kubectl apply -f basic.pod.yaml

print_and_wait "Notice that we attach a config map as a volume. Let's see it in the pod"
execute_command kubectl exec nginx-configmap -- ls /etc/user-config/
execute_command kubectl exec nginx-configmap -- cat /etc/user-config/editor.height
execute_command kubectl exec nginx-configmap -- cat /etc/user-config/editor.width
execute_command kubectl exec nginx-configmap -- cat /etc/user-config/store-name

print_and_wait "Updating config maps works only if we restart a pod after. This doesn't apply to config maps mounted as volumes."

print_and_wait "Now let's see that we have env variables available in our shell"
execute_command "kubectl exec nginx-configmap -- /bin/sh -c set | head -n 5"

print_and_wait "Cleaning up:"
execute_command kubectl delete configmaps --all # there is a k8s config map, which will be recreated when deleted
execute_command kubectl delete -f basic.pod.yaml
