#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Installing application as umbrella chart."

print_and_wait "Let's see how is the structure different for umbrella charts."
execute_command tree app_umbrella
execute_command cat app/app_umbrella/Chart.yaml

print_and_wait "The process is the same as for a traditional chart."
execute_command helm install catissimo app_umbrella

print_and_wait "...with all the resources"
execute_command kubectl get all

