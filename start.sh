#!/bin/bash

source ./.config/cli_utils.sh

echo 'Starting Kubernetes scripts environment'
echo
echo 'Preparing K8s cluster'
echo

./.config/prepare.sh
eval $(minikube -p minikube docker-env)
echo

function wait_for_user_action() {
  echo 
  echo '------------------------'
  echo 'Script finished. Do you want to:'
  echo -e '\t(n) go to the next script'
  echo -e '\t(r) repeat this script again'
  echo -e '\t(e) exit'

  while true; do
    read -n 1 -rs -p ': ' SELECTION
 
    case $SELECTION in
      [nN]):
        return 0
      ;;
    
      [rR]):
        return 0
      ;;
      
      [eE]):
        read -n 1 -r -p 'Are you sure? No more scripts will be executed. Type [y|Y] for yes:' DO_EXIT
        echo  # just to make space for next terminal line (nevermin if we exited or no)
        if [[ $DO_EXIT =~ [yY] ]]; then
          exit 0
        fi
      ;;
   
      *)
        echo "unknown option \"$SELECTION\", please try again"
      ;;
    esac
  done
}

function run_script() {
  PATH_TO_SCRIPT="$1"
  
  if [[ -z $PATH_TO_SCRIPT ]]; then
    echo "Failed to process script with path \"$PATH_TO_SCRIPT\""
    return 1
  fi
  SCRIPT_NAME=$(basename $PATH_TO_SCRIPT)
  SCRIPT_PATH=${PATH_TO_SCRIPT/$SCRIPT_NAME/}

  pushd $SCRIPT_PATH > /dev/null

  SHOULD_PERFORM_SCRIPT=1
  while [ $SHOULD_PERFORM_SCRIPT -eq 1 ]; do
    clear
    echo -e "\t====================="
    echo -e "\t= PERFORMING SCRIPT: $PATH_TO_SCRIPT"
    echo -e "\t====================="
    echo
    read -n 1 -rs -p 'Press any key to continue'
    echo
    
    # perform script
    ./$SCRIPT_NAME
    
    wait_for_user_action
    SHOULD_PERFORM_SCRIPT=$?
  done

  popd > /dev/null
}

export -f wait_for_user_action
export -f run_script

print_and_wait "press any key to continue..."

for SCRIPT in `find . -mindepth 2 -regex '.*\.sh$'`; do
  run_script $SCRIPT
done
