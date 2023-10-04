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
fi

echo
echo '-----------------------------------------------------------'
echo '| Preparation completed, you may try out the scripts now. |'
echo '-----------------------------------------------------------'
