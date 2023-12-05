#!/bin/bash


print_and_wait -C "Installing application as umbrella chart."

print_and_wait "Let's see how is the structure different for umbrella charts."
execute_command tree app_umbrella

print_and_wait "All globally-important information is in the Chart.yaml file which acts as a project description."
execute_command cat app_umbrella/Chart.yaml

print_and_wait "The 'charts' folder contains all the applications we would like to deploy for this specific chart. For now it has a backend and frontend application."
print_and_wait "Structure of those folder is usually similar with the difference that these applications don't define their own charts since they're already a part of another chart. If we would use other existing charts on the other hand, we would need to define them in dependencies section of the Chart.yaml file."
execute_command cat app_umbrella/charts/backend/Chart.yaml

print_and_wait "Templates folder inside the charts applications are typical K8s resource manifest files. Pods, deployments, configMaps, ..."
print_and_wait "They will get automatically picked up and deployed when that particular application is installed by helm."
execute_command cat app_umbrella/charts/backend/templates/deployment.yaml

print_and_wait "The installation process is the same as for a traditional chart."
execute_command helm install catissimo app_umbrella

print_and_wait "Listing all the resources..."
execute_command kubectl get all

print_and_wait "And cleaning up with a simple helm delete."
execute_command helm delete catissimo

