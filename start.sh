#!/bin/bash

source ./.config/cli_utils.sh

echo 'Starting Kubernetes scripts environment'
echo
echo 'Preparing K8s cluster'
echo

./.config/prepare.sh
eval $(minikube -p minikube docker-env)
export CURRENT_SCRIPT=

function exit_prompt() {
  read -n 1 -r -p 'Are you sure? No more scripts will be executed. Type [y|Y] for yes:' DO_EXIT
  echo  # just to make space for next terminal line (nevermin if we exited or no)
  if [[ $DO_EXIT =~ [yY] ]]; then
    exit 0
  fi
}

function script_starts_wait() {
  echo 'Do you want to:'
  echo -e '\t(r) run this script'
  echo -e '\t(s) skip and proceed to the next one'
  echo -e '\t(e) exit'

  SELECTION=""
  while true; do
    # don't prompt when user presses keys such as enter
    if [[ $SELECTION -eq "" ]]; then
      read -n 1 -rs SELECTION
    else
      read -n 1 -rs -p ': ' SELECTION
    fi
 
    case $SELECTION in
      [rR]):
        return 0
      ;;
    
      [sS]):
        return 1
      ;;
      
      [eE]):
        exit_prompt
      ;;
   
      *)
        if [[ ! -z $SELECTION ]]; then
          echo "unknown option \"$SELECTION\", please try again"
        fi
      ;;
    esac
  done
}

function script_finished_wait() {
  echo '------------------------'
  echo 'Script finished. Do you want to:'
  echo -e '\t(n) go to the next script'
  echo -e '\t(r) repeat this script again'
  echo -e '\t(e) exit'

  while true; do
    # don't prompt when user presses keys such as enter
    if [[ $SELECTION -eq "" ]]; then
      read -n 1 -rs SELECTION
    else
      read -n 1 -rs -p ': ' SELECTION
    fi
 
    case $SELECTION in
      [nN]):
        return 0
      ;;
    
      [rR]):
        return 1
      ;;
      
      [eE]):
        exit_prompt
      ;;
   
      *)
        if [[ ! -z $SELECTION ]]; then
          echo "unknown option \"$SELECTION\", please try again"
        fi
      ;;
    esac
  done
}

function run_script() {
  local PATH_TO_SCRIPT="$1"
  
  if [[ -z $PATH_TO_SCRIPT ]]; then
    echo "Failed to process script with path \"$PATH_TO_SCRIPT\""
    return 1
  fi
  local SCRIPT_NAME=$(basename $PATH_TO_SCRIPT)
  local SCRIPT_PATH=${PATH_TO_SCRIPT/$SCRIPT_NAME/}
  CURRENT_SCRIPT="$SCRIPT_NAME"

  pushd $SCRIPT_PATH > /dev/null

  local SHOULD_PERFORM_SCRIPT=1
  local IS_REPEATED="0"
  while [ $SHOULD_PERFORM_SCRIPT -eq 1 ]; do
    clear
    echo "=========="
    echo "== SCRIPT: $PATH_TO_SCRIPT"
    echo "=========="
    echo

    # don't inform about this when we repeat the script
    if [ $IS_REPEATED -eq "0" ]; then
      # does the user want to run, skip or exit
      script_starts_wait
      if [[ "$?" -eq "1" ]]; then
        break
      fi
    fi
    
    # perform script
    ./$SCRIPT_NAME
    echo
    
    # does the user want to run again, continue or exit
    script_finished_wait

    SHOULD_PERFORM_SCRIPT=$?
    IS_REPEATED=$SHOULD_PERFORM_SCRIPT
  done

  popd > /dev/null
}

export -f script_finished_wait
export -f run_script

print_and_wait "press any key to continue..."
for SCRIPT in `find . -mindepth 2 -regex '.*\.sh$' -not -path './.config/*' -not -path './playtest/*'`; do
  run_script $SCRIPT
done

echo
echo '=========================='
echo 'End of playground examples'
echo '=========================='
