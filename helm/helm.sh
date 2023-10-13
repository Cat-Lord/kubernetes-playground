#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"

print_and_wait -c "Helm demonstration"

print_and_wait "Having Helm installed we need to provide a repository to fetch charts from. The parameter after 'add' is our local name for the added repository."
execute_command helm repo add bitnami https://charts.bitnami.com/bitnami

print_and_wait "Below is a list of currently available repositories."
execute_command helm repo list

print_and_wait "After adding a repository we need to call update to fetch all the available chart metadata."
execute_command helm repo update

print_and_wait "Now we can install a chart from a repository like this:"
execute_command helm install grafana bitnami/grafana

print_and_wait "Notice that we need to reference the repository and a chart in that repository like so 'repo/chart'. We also provide our local name to that resource ('grafana' in this case)."
print_and_wait "Let's see if that resource is now available in K8s..."
execute_command kubectl get all

print_and_wait "Above we see a nice overview of pods, deployments, services and replica sets created through our new grafana chart"
print_and_wait "Let's also check secrets."
execute_command kubectl get secrets

print_and_wait "Removing is just as simple. We refer to the resource by the name we've given it."
execute_command helm uninstall grafana

print_and_wait "We should now see the cluster in the initial state again"
execute_command kubectl get all
execute_command kubectl get secrets
