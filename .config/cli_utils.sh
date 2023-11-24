#!/bin/bash


function print_and_wait() {
  # clearing the console
  if [[ $1 == "--clean" || $1 == "-c" ]]; then
    clear;
    shift 1
  fi

  # colored output
  if [[ $1 == "--colored" || $1 == "-co" ]]; then
    # bold text with blue color
    ACCENT_COLOR="\e[1;36m"
    NORMAL_COLOR="\e[0m"
    shift 1
  else
    # normal text with purple color
    ACCENT_COLOR="\e[0;35m"
  fi

  MESSAGE="$@"
  echo -e "> ${ACCENT_COLOR}${MESSAGE}${NORMAL_COLOR}"
  read -n 1 -r -s
}

function execute_command() {
  args="$@"
  print_and_wait -co "$ $args"
  eval $args			# keeps quotes
  echo
}

function expect_nodes() {
  EXPECTED_NODES="$1"

  if [[ -z $EXPECTED_NODES || ! $EXPECTED_NODES =~ ^[[:digit:]]{1,2}$ || $EXPECTED_NODES == "0" ]]; then
    echo "usage: expect_nodes <number 1-99>"
    exit 111
  fi

  ACTUAL_NODES=`minikube node list | wc -l`
  
  if [[ $ACTUAL_NODES -lt $EXPECTED_NODES ]]; then
    echo "Error: Expecting $EXPECTED_NODES node(s) but cluster currently has $ACTUAL_NODES node(s). Please, add new nodes with 'minikube node add' and run this example again."
    exit 1
  elif [[ $ACTUAL_NODES -gt $EXPECTED_NODES ]]; then
    echo "Warning: Expecting $EXPECTED_NODES node(s) but cluster currently has $ACTUAL_NODES node(s). This might or might not affect the outcome of this example. Proceed with care."
  fi
}

# necessary export for usage outside of this script
export -f print_and_wait
export -f execute_command
export -f expect_nodes
