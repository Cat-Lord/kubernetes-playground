#!/bin/bash


function print_and_wait() {
  # clearing the console
  if [[ $1 == "--clean" || $1 == "-c" ]]; then
    clear;
    shift 1
  fi

  # colored output
  if [[ $1 == "--colored" || $1 == "-co" ]]; then
    ACCENT_COLOR="\e[1;34m"
    NORMAL_COLOR="\e[0m"
    shift 1
  else
    ACCENT_COLOR="\e[0m"
  fi

  MESSAGE="$@"
  echo -e "${ACCENT_COLOR}${MESSAGE}${NORMAL_COLOR}";
  read -n 1 -r -s
}

function execute_command() {
  args=$@
  print_and_wait -co "$ $args"
  $@
  echo
}

print_and_wait -c "Pod sample where we create and delete a pod. Press any key to start"

echo "List of all pods"
execute_command kubectl get pods

print_and_wait "Now let's create a sample pod"
execute_command kubectl run my-nginx --image=nginx:alpine

print_and_wait "Let's now see the details of the newly created pod"
execute_command kubectl describe pod my-nginx

print_and_wait "Finally, let's delete the pod"
execute_command kubectl delete pod my-nginx

print_and_wait "...and verify it"
execute_command kubectl describe pod my-nginx
