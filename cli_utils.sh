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
