#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Helm Templating in action"
echo;

print_and_wait "We are going to create sample application with backend and frontend both being Nginx servers exposed out."
print_and_wait "Note that this is not a working example application. It should install without issues but shouldn't be accessible from the outside (Ingress config not working properly)."
echo;

print_and_wait "These servers will use some templating configuration for deployment and also print out some tepmlated messages."
execute_command tree templating
execute_command cat templating/charts/backend/values.yaml
echo
execute_command cat templating/charts/frontend/values.yaml

print_and_wait "We are also able to check the installation before running it like this:"
execute_command helm template templating

print_and_wait "The process is the same as for a traditional chart."
execute_command helm install catissimo templating --atomic
print_and_wait "Notice the 'atomic' option above. Even when errors occur, helm will create the installation. This option prevents it."

print_and_wait "Let's confirm the installation by looking at the resources"
execute_command kubectl get all

print_and_wait "And cleaning up.."
execute_command helm delete catissimo

print_and_wait "This demonstration was a quick one, make sure to check the charts in the templating folder yourself to see more."

