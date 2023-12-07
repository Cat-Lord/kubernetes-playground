#!/bin/bash

echo 'Loading CLI utils...'
source "$(dirname $0)"/cli_utils.sh
if [[ ! "$?" == 0 ]]; then
  echo 'CLI utils failed to load. Please, verify if the .config folder contains all necessary files and try again.'
  exit 1
fi

chmod +x *.sh

MINIKUBE_RUNNING_SVC_COUNT=`minikube status | grep -i running | wc -l`
if [[ "$?" -ne 0 ]]; then
  print_and_wait --no-wait --warn 'Error: Minikube failed to start. Make sure you have minikube installed and try again.'
  exit 1
fi

# start minikube only if it's not already up
if [[ $MINIKUBE_RUNNING_SVC_COUNT -eq 0 ]]; then
  print_and_wait --no-wait 'Starting minikube. This may take a moment...'
  minikube start --memory=4g --cpus=4 --driver=docker --cni=calico
fi

which docker 1>/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
  print_and_wait --no-wait --warn "Error: Docker could not be found. Check if it's installed and if you have proper permissions."
  exit 2
fi

eval $(minikube -p minikube docker-env)
if [[ "$?" -ne 0 ]]; then
  print_and_wait --no-wait --warn  'Error: could not attach docker to minikube.'
  exit 3
else
  print_and_wait --no-wait  'Setting docker context to "minikube"'
  docker context inspect minikube 1>/dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    print_and_wait --no-wait ' * Context not found, creating a new one'
    docker context create minikube 1>/dev/null 2>&1
  fi

  # DOCKER_HOST would override the context
  unset DOCKER_HOST
  docker context use minikube 1>/dev/null 2>&1
fi

which helm 1>/dev/null 2>&1
if [[ ! "$?" -eq 0 ]]; then
  print_and_wait --no-wait --warn '[Warning] Helm installation not found. You may continue, but some examples might not work as expected'
fi

cat << EOF
'-----------------------------------------------------------'
'| Preparation complete, you may try out the scripts now.  |'
'-----------------------------------------------------------'

EOF
