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
    return 0
  fi
  return 1
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

# Takes a path to script as argument and runs respective script
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
  ./$SCRIPT_NAME

  print_and_wait "...press any key to go back to the menu"
  popd > /dev/null
}

# tried using getops, fuck that
function show_navigation() {
  local PREVIOUS_SCRIPT_TEXT="(p) previous script"
  local NEXT_SCRIPT_TEXT="(n) next script"
  local HAS_PREV=""
  local HAS_NEXT=""
  local SCRIPT_NAME=""
  
  ARG="$1"
  while [ ! -z "$ARG" ]; do
    case "$ARG" in
      -s)
        shift
        if [ -z "$1" ]; then
          SCRIPT_NAME="unkown"
          print_and_wait --no-wait --warn "Script name missing, skipping"
        else
          SCRIPT_NAME="$1"
        fi
        ;;
      -p)
        HAS_PREV="true"
        shift 
        PREVIOUS_SCRIPT="Previous: $1"
        ;;
      -n)
        HAS_NEXT="true"
        shift
        NEXT_SCRIPT="Next: $1"
        ;;
    esac
    shift
    ARG="$1"
  done

  # replacing all characters with spaces
  if [[ -z "$HAS_PREV" ]]; then
    PREVIOUS_SCRIPT_TEXT=`echo $PREVIOUS_SCRIPT_TEXT | sed -e 's/./ /g'`
  fi
  if [[ -z "$HAS_NEXT" ]]; then
    NEXT_SCRIPT_TEXT=`echo $NEXT_SCRIPT_TEXT | sed -e 's/./ /g'`
  fi

  local LIGHT="\e[0;37m"
  clear
  echo -e "$LIGHT================"
  echo -e "== \e[0;36m${PREVIOUS_SCRIPT}${LIGHT}"
  echo -e "==== \e[0;32mCurrent script: ${SCRIPT_NAME}$LIGHT"
  echo -e "== \e[0;36m$NEXT_SCRIPT$LIGHT"
  echo -e '================\e[0m'
  cat << EOF 
  
$PREVIOUS_SCRIPT_TEXT     (r) run current script     $NEXT_SCRIPT_TEXT
                        (l) list all scrits
                        (e) exit
EOF
}

# Takes a number and an interval and clamps the number
# to that interval.
# Args:
# - number to clamp
# - minimum
# - maximum
# Examples:
#   clamp 5 1 10    # clamp number 5 between 1 and 10 (returns 5, unchanged)
#   clamp 1 5 10    # clamp number 1 between 5 and 10 (returns 5, the minimum)
#   clamp 10 1 10   # clamp number 10 between 1 and 10 (returns 9, the maximum minus one)
function clamp() {
  NUM=$1
  MIN=$2
  MAX=$3

  if [[ $NUM -le $MIN ]]; then
    NUM=$MIN
  fi

  if [[ $NUM -ge $MAX ]]; then
    NUM=$(($MAX - 1))
  fi
}

function start_playground() {
  local ALL_SCRIPTS=(`find . -mindepth 2 -regex '.*\.sh$' -not -path './.config/*' -not -path './playtest/*'`)
  local SCRIPTS_COUNT=${#ALL_SCRIPTS[@]}
  
  print_and_wait --no-wait "Found $SCRIPTS_COUNT scripts"
  
  if [[ $SCRIPTS_COUNT == 0 ]]; then
    print_and_wait --no-wait --warn 'No scripts available to run.'
    exit 0
  fi

  local CURRENT_SCRIPT_INDEX=0
  local PREVIOUS=""
  local PREVIOUS_SCRIPT=""
  local NEXT=""
  local NEXT_SCRIPT=""
  
  # Script seletion
  while true; do
    if [[ $CURRENT_SCRIPT_INDEX -gt 0 ]]; then
      PREVIOUS="-p"
      PREVIOUS_SCRIPT="${ALL_SCRIPTS[$(( $CURRENT_SCRIPT_INDEX - 1 ))]}"
    else 
      PREVIOUS=""
      PREVIOUS_SCRIPT=""
    fi
  
    if [[ $CURRENT_SCRIPT_INDEX -lt $(( $SCRIPTS_COUNT - 1 )) ]]; then
      NEXT="-n"
      NEXT_SCRIPT="${ALL_SCRIPTS[$(( $CURRENT_SCRIPT_INDEX + 1 ))]}"
    else 
      NEXT=""
      NEXT_SCRIPT=""
    fi
  
    show_navigation $PREVIOUS $PREVIOUS_SCRIPT $NEXT $NEXT_SCRIPT -s "${ALL_SCRIPTS[$CURRENT_SCRIPT_INDEX]}"
    read -n 1 -rs -p ': ' USER_ACTION
  
    case $USER_ACTION in
      [lL])
        echo -e "\n${ALL_SCRIPTS[@]}" | tr ' ' '\n'
        print_and_wait '...press anything to continue'
        ;;
      [pP])
        if [[ ! -z $PREVIOUS ]]; then
          CURRENT_SCRIPT_INDEX=$(($CURRENT_SCRIPT_INDEX - 1))
        fi
        ;;
      [nN])
        if [[ ! -z $NEXT ]]; then
          CURRENT_SCRIPT_INDEX=$(($CURRENT_SCRIPT_INDEX + 1))
        fi
        ;;
      [rR])
        run_script ${ALL_SCRIPTS[$CURRENT_SCRIPT_INDEX]}
        ;;
      [eE])
        exit_prompt
        if [[ "$?" == 0 ]]; then
          return 0
        fi ;;
    esac
    
    clamp CURRENT_SCRIPT_INDEX 0 ${#ALL_SCRIPTS[@]} 
  done
}

print_and_wait "press any key to continue..."

# MAIN
start_playground

echo
echo '=========================='
echo 'End of playground examples'
echo '=========================='
