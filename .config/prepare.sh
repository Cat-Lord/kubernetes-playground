chmod +x *.sh

MINIKUBE_RUNNING_SVC_COUNT=`minikube status | grep -i running | wc -l`
if [[ "$?" -ne 0 ]]; then
  echo 'Error: Minikube failed to start. Make sure you have minikube installed and try again.'
  exit 1
fi

# start minikube only if it's not already up
if [[ $MINIKUBE_RUNNING_SVC_COUNT -eq 0 ]]; then
  echo 'Starting minikube. This may take a moment...'
  minikube start
fi

which docker 1>/dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
  echo "Error: Docker could not be found. Check if it's installed and if you have proper permissions."
  exit 2
fi

eval $(minikube -p minikube docker-env)
if [[ "$?" -ne 0 ]]; then
  echo 'Error: could not attach docker to minikube.'
  exit 3
else
  echo 'Setting docker context to "minikube"'
  docker context inspect minikube 1>/dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    echo ' * Context not found, creating a new one'
    docker context create minikube 1>/dev/null 2>&1
  fi

  # DOCKER_HOST would override the context
  unset DOCKER_HOST
  docker context use minikube 1>/dev/null 2>&1
fi

which helm 1>/dev/null 2>&1
if [[ ! "$?" -eq 0 ]]; then
  echo '[Warning] Helm installation not found. You may continue, but some examples might not work as expected'
fi

echo
echo '-----------------------------------------------------------'
echo '| Preparation complete, you may try out the scripts now.  |'
echo '-----------------------------------------------------------'
echo
