chmod +x *.sh
echo 'Starting minikube. This may take a moment...'
minikube start 1>&2 2>/dev/null

if [[ "$?" -ne 0 ]]; then
  echo 'Error: Minikube failed to start. Make sure you have minikube installed and try again.'
  exit 1
fi

which docker 2>&1 1>/dev/null
if [[ "$?" -ne 0 ]]; then
  echo "Error: Docker could not be found. Check if it's installed and if you have proper permissions."
  exit 2
fi

eval $(minikube -p minikube docker-env)
if [[ "$?" -ne 0 ]]; then
  echo 'Error: could not attach docker to minikube.'
  exit 3
else
  docker context inspect minikubes 1>/dev/null 2>&1
  if [[ "$?" -ne 0 ]]; then
    docker context create minikube
  fi

  # DOCKER_HOST would override the context
  unset DOCKER_HOST
  docker context use minikube
fi

echo
minikube addons enable ingress
echo

which helm 2>&1 1>/dev/null

if [[ ! "$?" -eq 0 ]]; then
  echo '[Warning] Helm installation not found. You may continue, but some examples might not work as expected'
  echo
fi

echo
echo '-----------------------------------------------------------'
echo '| Preparation complete, you may try out the scripts now. |'
echo '-----------------------------------------------------------'
echo
echo 'Please run the following commands in your shell to continue'
echo 'eval $(minikube -p minikube docker-env)'
echo 'minikube tunnel'
echo
echo '(Optionally)'
echo alias k="kubectl"
