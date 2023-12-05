#!/bin/bash


print_and_wait -C "RBAC basic configuration and playing around"

print_and_wait "First we define a role with access to services and we bind that role to a service account:"
execute_command cat rbac/basic.roles.yaml

print_and_wait "Let's create it"
execute_command kubectl create -f rbac/basic.roles.yaml

print_and_wait "Now we can create the service account"
execute_command kubectl create serviceaccount service-reader

print_and_wait "And let's also create a token. This is an additional step (TODO)"
execute_command kubectl create -f rbac/manual.secret.yaml

# TODO: this script :D

print_and_wait "Cleanup"
execute_command kubectl delete -f rbac/manual.secret.yaml
execute_command kubectl delete serviceaccount service-reader
execute_command kubectl delete -f rbac/basic.roles.yaml
