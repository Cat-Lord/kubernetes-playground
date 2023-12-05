#!/bin/bash


print_and_wait -C "Secrets in K8s"

print_and_wait "We can create secrets from the input params like with config maps (quotation may be necessary in case we use some weird characters):"
execute_command kubectl create secret generic sample-secret --from-literal=myProperty=myValue
execute_command kubectl describe secret sample-secret

print_and_wait "Using K8s config files to create them is possible but risky. They are only base64 encoded."
execute_command cat not_secure.secret.yaml
execute_command kubectl apply -f not_secure.secret.yaml

print_and_wait "There are different types of secrets. The most flexible is the 'opaque', which has arbitrary data. We also have secrets for ssh, tls and others. Below we create a token secret."
execute_command cat token.secret.yaml
execute_command kubectl create -f token.secret.yaml

print_and_wait "Following commands can work in testing environments but normally it's disabled in real clusters (we might need an associated permission)"
execute_command kubectl get secrets
execute_command kubectl describe secret login-secret
execute_command kubectl get secret login-secret -o yaml

print_and_wait "Usage of secrets is similar to traditional config maps"
execute_command cat basic.pod.yaml
execute_command kubectl apply -f basic.pod.yaml
sleep 2

print_and_wait "Now let's query the environment variable we loaded in the config above"
execute_command kubectl exec pod-with-secret -- /bin/sh -c  "'"'echo $LOGIN_SECRET_PASSWORD'"'"

print_and_wait "We also get a volume as configured in the Pod yaml."
execute_command kubectl exec pod-with-secret -- cat etc/logins/username
execute_command kubectl exec pod-with-secret -- cat etc/logins/password

print_and_wait "Final cleanup"
execute_command kubectl delete -f basic.pod.yaml --now
execute_command kubectl delete secrets --all
