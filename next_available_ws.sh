#!/bin/bash

# get workspace numbers
WS_STRING=$(i3-msg -t get_workspaces   | jq '.[] | (.num)')
WS_ARRAY=()

# put workspace numbers into array
for ws in $WS_STRING; do WS_ARRAY+=($ws); done

# list of all possible workspaces (change if you have more)
ALL_WS=({1..10})


# return 0 if element in array, 1 otherwise
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

moveContainer () {
  ACTIVE_WIN=$(xprop -id $(xdotool getactivewindow) | grep 'WM_NAME(STRING)' | cut -d'"' -f2)
  i3-msg move container to workspace $ws
  wmctrl -r $ACTIVE_WIN -b add,demands_attention
}

# check for move container flag
moveContainerFlag=false
moveContainerAndFocusFlag=false
while getopts ':fm' opt; do
    case $opt in
        f) moveContainerAndFocusFlag=true ;;
        m) moveContainerFlag=true ;;
        *) echo 'Error in command line parsing' >&2
            exit 1
    esac
done

# loop through all workspaces and find first that isn't in use
for ws in ${ALL_WS[@]}
do
    if  ! containsElement $ws "${WS_ARRAY[@]}"
    then
        if "$moveContainerAndFocusFlag"
        then
          moveContainer
          i3-msg workspace number $ws
        else
          if "$moveContainerFlag"
          then
            moveContainer
          else
              i3-msg workspace number $ws
          fi
        fi
        break
    fi
done
