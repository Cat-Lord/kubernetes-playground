#!/bin/bash

# get parent directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/../cli_utils.sh"
SOURCES_DIR="zero_downtime_samples"

pushd ./${SOURCES_DIR}
trap 'popd &> /dev/null && exit 0' INT	# handle return to previous working dir when exiting

function build_and_deploy() {
  VERSION=$1
  if [[ -z $1 ]]; then
    VERSION="1.0"
    echo "Warn: build_and_deploy expects a single argument of version in the form '<version-number>.0'. Using default '1.0'"
  fi

  if [[ ! "$VERSION" =~ [1-4]\.0 ]]; then
    VERSION="1.0"
    echo "Warn: Incorrect version $1 specified, using default version 1.0"
  fi

  PRIMARY_VERSION=${VERSION:0:1}
  DEPLOYMENT_FILE="node-app-v${PRIMARY_VERSION}.deployment.yaml"

  execute_command docker build -t meowness-app:${VERSION} v${PRIMARY_VERSION}
  print_and_wait "The deployment file:"
  cat $DEPLOYMENT_FILE; echo; echo
  print_and_wait "Running the deployment"
  execute_command kubectl apply -f $DEPLOYMENT_FILE
}

print_and_wait -c "Zero-downtime deployment with rolling updates of a node application"

print_and_wait "Before we start we need to create a load-balancer service to correctly route our traffic."
print_and_wait "The service is really simple as we can see here:"
cat "node-app-load-balancer.service.yaml"; echo; echo;
execute_command kubectl apply -f "node-app-load-balancer.service.yaml"

print_and_wait "Let's start with version 1.0"
build_and_deploy "1.0"

print_and_wait "Getting all resources reveals our new node application"
execute_command kubectl get all

print_and_wait "We need to know the URL our application accessible from. This is done with minikube and it differs a bit in real production environment."
execute_command minikube service meowness-app --url

print_and_wait "Let's see it in the browser navigating to that URL. If this doesn't work, navigate to the URL above manually in the browser."
execute_command sensible-browser `minikube service meowness-app --url` 2> /dev/null

print_and_wait "Finally clean up the deployment"
execute_command kubectl delete -f "node-app-load-balancer.service.yaml" && kubectl delete deployments --all		# TODO clean up the last deployed thing
