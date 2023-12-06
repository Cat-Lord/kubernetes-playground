#!/bin/bash

# put every function between the 'set -a' and this 'set +a'
# to have them automatically exported to the outer env
set -a

function print_script_name() {
  SCRIPT_NAME_LENGTH=${#CURRENT_SCRIPT}
  if [[ $SCRIPT_NAME_LENHGT == 0 ]]; then
    return 1
  fi

  local SEQ=$(seq $SCRIPT_NAME_LENGTH)
  printf -- '-%.0s' $SEQ; echo   # echo '-' as many times as the script name length
  echo "$CURRENT_SCRIPT"
  printf -- '-%.0s' $SEQ; echo
  echo
  echo
}

# Prints and waits for user interaction to proceed.
# Args:
# --warn, -w: Prints the message with a warning appeal.
# --clean, -C: Clears the whole screen and prints (notice capital C).
# --no-wait, -n: Prints the message without waiting for user interaction.
# --command, -c: Prints colored and bold output.
function print_and_wait() {
  local STOP_PARSING_ARGS=""
  local MESSAGE=""
  local PREFIX="> "
  local NORMAL_COLOR="\e[0m"
  local ACCENT_COLOR="\e[0;35m"
  local WARN_COLOR="\e[1;31m"
  local NO_WAIT=""
 
  for arg in $@; do
    # process only if arg starts with '-' or '--'
    if [[ -z "$arg" ]]; then
      echo 'print_and_wait: No message to print'
      return 1

    elif [[ -z $STOP_PARSING_ARGS && "$arg" =~ --?.* ]]; then
      # clearing the console
      if [[ $arg == "--clean" || $arg == "-C" ]]; then
        clear

        # if we know name of the current script, keep it as header after clearing the screen
        if [[ ! -z $CURRENT_SCRIPT ]]; then
          print_script_name
        fi
      fi
      
      if [[ $arg == "--no-wait" || $arg == "-n" ]]; then
        NO_WAIT="true"
        PREFIX=""
      fi

      if [[ $arg == "--warn" || $arg == "-w" ]]; then
        # bold text with blue color
        ACCENT_COLOR="$WARN_COLOR"
      fi

      # colored output
      if [[ $arg == "--command" || $arg == "-c" ]]; then
        # bold text with blue color
        ACCENT_COLOR="\e[1;36m"
      fi
    else
      if [[ -z "$STOP_PARSING_ARGS" ]]; then
        MESSAGE="$arg"
        STOP_PARSING_ARGS="true"
      else
        MESSAGE+=" $arg"
      fi
    fi
  done

  echo -e "${PREFIX}${ACCENT_COLOR}${MESSAGE}${NORMAL_COLOR}"

  if [[ -z $NO_WAIT ]]; then
   read -n 1 -r -s
  fi
}

# Prints and executes obtained command. Before executing a 
# command, waits for user input.
# Args:
# --no-wait, -n: Prints the command and immediately.
# --no-exec, -E: Prints the command and immediately.
function execute_command() {
  local STOP_PARSING_ARGS=""
  local MESSAGE=""
  local NO_WAIT=""
  local NO_EXEC=""
 
  for arg in $@; do
    # process only if arg starts with '-' or '--'
    if [[ -z "$arg" ]]; then
      echo 'print_and_wait: No message to print'
      return 1

    elif [[ -z $STOP_PARSING_ARGS && "$arg" =~ --?.* ]]; then
      
      # don't wait for execution of the command, just print it
      if [[ $arg == "--no-wait" || $arg == "-n" ]]; then
        NO_WAIT="--no-wait"
      fi

      if [[ $arg == "--no-exec" || $arg == "-E" ]]; then
        NO_EXEC="--no-exec"
      fi
    else
      if [[ -z "$STOP_PARSING_ARGS" ]]; then
        MESSAGE="$arg"
        STOP_PARSING_ARGS="true"
      else
        MESSAGE+=" $arg"
      fi
    fi
  done

  print_and_wait --command "$NO_WAIT" "$ $MESSAGE"
  if [[ -z "$NO_EXEC" ]]; then
    # eval keeps quoting almost perfectly as required
    eval $MESSAGE 
  fi
  echo
}

function expect_nodes() {
  local EXPECTED_NODES="$1"

  if [[ -z $EXPECTED_NODES || ! $EXPECTED_NODES =~ ^[[:digit:]]{1,2}$ || $EXPECTED_NODES == "0" ]]; then
    echo "usage: expect_nodes <number 1-99>"
    exit 111
  fi

  local ACTUAL_NODES=`minikube node list | wc -l`
  if [[ $ACTUAL_NODES -lt $EXPECTED_NODES ]]; then
    echo "Error: Expecting $EXPECTED_NODES node(s) but cluster currently has $ACTUAL_NODES node(s). Please, add new nodes with 'minikube node add' and run this example again."
    exit 1
  elif [[ $ACTUAL_NODES -gt $EXPECTED_NODES ]]; then
    echo "Warning: Expecting $EXPECTED_NODES node(s) but cluster currently has $ACTUAL_NODES node(s). This might or might not affect the outcome of this example. Proceed with care."
  fi
}

# put every function between the 'set -a' and this 'set +a'
# to have them automatically exported to the outer env
set +a
