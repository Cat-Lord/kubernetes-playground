#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "RBAC basic configuration and playing around"

print_and_wait "First we define a role with access to services and we bind that role to a service account:"
execute_command cat rbac/basic.roles.yaml

print_and_wait "Let's create it"
execute_command kubectl create -f rbac/basic.roles.yaml

print_and_wait "Now we can create the service account"
execute_command kubectl create serviceaccount service-reader

print_and_wait "And let's also create a token. This is an additional step (TODO)"
execute_command kubectl create -f rbac/manual.secret.yaml
