#!/bin/bash

source ./cli_utils.sh

echo 'Starting Kubernetes scripts environment'
echo
echo 'Preparing K8s cluster'
echo

export -f print_and_wait
export -f execute_command
export -f expect_nodes

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
        exit 1
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
    echo -e "\t======================="
    echo -e "\t== PERFORMING SCRIPT =="
    echo -e "\t$ $PATH_TO_SCRIPT"
    echo
    echo
    #./$SCRIPT_NAME
    wait_for_user_action
    SHOULD_PERFORM_SCRIPT=$?
  done

  popd > /dev/null
}

export -f wait_for_user_action
export -f run_script

find . -mindepth 2 -regex '.*\.sh$' -exec bash -c 'run_script "$@"' bash {} \;

