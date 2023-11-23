#!/bin/bash

SOURCES_DIR="zero_downtime_samples"

pushd ./${SOURCES_DIR} 2>&1 1>/dev/null
trap 'popd &> /dev/null && exit 0' INT	# handle return to previous working dir when exiting

function build_and_deploy() {
  VERSION=$1
  if [[ -z $1 ]]; then
    VERSION="1.0"
    echo "Warn: build_and_deploy expects a single argument of version in the form '<version-number>.0'. Using default '1.0'"
  fi

  if [[ ! "$VERSION" =~ [1-4]\.0 ]]; then
    VERSION="1.0"
    echo "Warn: Incorrect version $VERSION specified, using default version 1.0"
  fi

  PRIMARY_VERSION=${VERSION:0:1}
  DEPLOYMENT_FILE="node-app-v${PRIMARY_VERSION}.deployment.yaml"
  
  execute_command docker build -t meowness-app:${VERSION} v${PRIMARY_VERSION}
  print_and_wait "The deployment file:"
  cat $DEPLOYMENT_FILE; echo; echo
  print_and_wait "Running the deployment"
  execute_command kubectl apply -f $DEPLOYMENT_FILE
}


###           ###
## Preparation ##
###           ###
print_and_wait -c "Zero-downtime deployment with rolling updates of a node application"
echo; print_and_wait "Enabling minikube tunnel to redirect requests to pods from localhost..."
minikube tunnel &

print_and_wait "Creating a load-balancer service to correctly route our traffic."
print_and_wait "The service is really simple as we can see here:"
cat "node-app-load-balancer.service.yaml"; echo; echo;
execute_command kubectl apply -f "node-app-load-balancer.service.yaml"

###         ###
## Version 1 ##
###         ###
print_and_wait "Let's start with version 1.0"
build_and_deploy "1.0"

print_and_wait "Getting all resources reveals our new node application"
execute_command kubectl get all

print_and_wait "We need to know the URL our application accessible from. This is done with minikube and it differs a bit in real production environment."
execute_command minikube service meowness-app --url

print_and_wait "Let's see it in the browser navigating to that URL. If this doesn't work, navigate to the URL above manually in the browser."
execute_command sensible-browser `minikube service meowness-app --url` 2> /dev/null

###         ###
## Version 2 ##
###         ###
print_and_wait "Let's deploy version 2.0"
build_and_deploy "2.0" "1.0"
kubectl get pods

print_and_wait "Above you see the pods immediately after we deployed last changes"
print_and_wait "Getting the pods again we now see that the v1 pods are being terminated. This can take some time to fully finish, let's move on."
execute_command kubectl get pods

kubectl get pods

print_and_wait "Now version 3.0"
build_and_deploy "3.0" "2.0"

print_and_wait "And lastly, version 4.0"
build_and_deploy "4.0" "3.0"

print_and_wait "Finally clean up the deployment"
execute_command kubectl delete all -l app=meowness-app --now
