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
print_and_wait -C "Zero-downtime deployment with rolling updates of a node application"
echo
print_and_wait "Enabling minikube tunnel to redirect requests to pods from localhost..."
print_and_wait "WARNING: Make sure to run minikube tunnel in a separate terminal session."
echo

print_and_wait "Creating a load-balancer service to correctly route our traffic. It will pick up new pods dynamically as we go without our intervention (we only need to deploy :)."
execute_command cat "node-app-load-balancer.service.yaml"
echo
execute_command kubectl apply -f "node-app-load-balancer.service.yaml"

###         ###
## Version 1 ##
###         ###
print_and_wait "Let's start deployment of app version 1.0"
build_and_deploy "1.0"

print_and_wait "Getting all resources reveals our new node application"
execute_command kubectl get all

print_and_wait "We need to know the URL our application accessible from. This is done with minikube and it differs from a real production environment."
execute_command minikube service meowness-app --url

print_and_wait "Let's see it in the browser navigating to that URL. If this doesn't work, navigate to the URL above manually in the browser."
APP_URL=`minikube service meowness-app --url`
execute_command sensible-browser $APP_URL 2> /dev/null
print_and_wait "We can now keep this window open and see how it changes output based on current deployment."
print_and_wait "If we refresh and get to the same pod more than 5 times we will get an internal error (just as a demonstration). Try it :)"
print_and_wait "You may have noticed that refreshing doesn't load-balance the traffic even though we have multiple running pods. This is because browsers create a stable connection which they keep alive so that we avoid scenarios when user gets a completely new application instance and the cache is empty or their unsaved changes are not propagated to the app database (or other similar scenario)."
print_and_wait "If we wanted to check the load-balancing, we can utilize tools such as curl, let's run it a couple of times:"
for i in {1..5}; do
  curl -s $APP_URL
  sleep 0.5
done
echo

###         ###
## Version 2 ##
###         ###
print_and_wait "Let's deploy version 2.0"
build_and_deploy "2.0" "1.0"
kubectl get pods

print_and_wait "Above you see the pods immediately after we deployed last changes"
print_and_wait "Getting the pods again we now see that the v1 pods are being terminated. This can take some time to fully finish and can be observed with --watch option as in many other scripts in this playground. Let's see the pods now and move on."
kubectl get pods
echo

###         ###
## Version 3 ##
###         ###
print_and_wait "Now version 3.0"
build_and_deploy "3.0" "2.0"

###         ###
## Version 4 ##
###         ###
print_and_wait "And lastly, version 4.0"
build_and_deploy "4.0" "3.0"

print_and_wait "Finally clean up the deployment (some might take a little bit of time)"
print_and_wait "Ways to delete deployments are plenty, here is one suggestion based on labels: kubectl delete all -l app=meowness-app"
print_and_wait "We can target the last deployment, becausea we remove the previous one automatically in the background. Just to verify:"
execute_command kubectl get rs
print_and_wait "Let's delete all"
execute_command kubectl delete -f node-app-v4.deployment.yaml --now
print_and_wait "Wait until pods get deleted and continue with CTRL+C."
execute_command docker image rm meowness-app:1.0
execute_command docker image rm meowness-app:2.0
execute_command docker image rm meowness-app:3.0
execute_command docker image rm meowness-app:4.0
