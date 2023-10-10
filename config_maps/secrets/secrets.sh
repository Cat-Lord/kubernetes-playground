#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../../cli_utils.sh"

print_and_wait -c "Secrets in K8s"

print_and_wait "We can create secrets manually like with config maps"
execute_command kubectl create secret generic sample-secret --from-literal=myProperty=myValue

print_and_wait "Using K8s config files to create them is possible but risky. They are only base64 encoded."
execute_command cat not_secure.secret.yaml
execute_command kubectl apply -f not_secure.secret.yaml

print_and_wait "Following commands can work in testing environments but normally it's disabled in real clusters (we might need an associated permission)"
execute_command kubectl get secrets
execute_command kubectl describe secret login-secret
execute_command kubectl get secret login-secret -o yaml

print_and_wait "Usage of secrets is similar to traditional config maps"
execute_command cat basic.pod.yaml
execute_command kubectl apply -f basic.pod.yaml

print_and_wait "Now let's query the environment variable we loaded in the config above"
# quotation disappears when put as argument of a function
echo 'kubectl exec nginx-secret --stdin --tty -- /bin/sh -c '"'echo \$LOGIN_SECRET_PASSWORD'"''
kubectl exec nginx-secret --stdin --tty -- /bin/sh -c 'echo $LOGIN_SECRET_PASSWORD'

print_and_wait "We also get a volume as configured in the Pod yaml."
execute_command kubectl exec nginx-secret --stdin --tty -- cat etc/logins/username
execute_command kubectl exec nginx-secret --stdin --tty -- cat etc/logins/password

print_and_wait "Final cleanup"
execute_command kubectl delete -f basic.pod.yaml
execute_command kubectl delete secrets --all
