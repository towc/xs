#!/usr/bin/zsh
(
local security=500
local macroStack=
typeset -A macros

function useLine {
  local line=$1
  local type="${line:0:1}"
  local amount="${line:1:1}"
  local flag=$amount
  local content="${line:2:#line}"
  local skipSleep=

  if ! [[ $amount =~ '[0-9]' ]]; then
    amount=1
  fi

  for run in {1..$amount}; do
    ((security--))
    if [ "$security" = '0' ]; then
      echo "exiting after too many commands"
      exit 1
    fi

    case "$type" in
      ';')
        skipSleep=true
        ;;
      '!')
        xdotool key --delay 20 ctrl+space
        notify $content
        skipSleep=true
        ;;
      'f')
        macros[$flag]+="${content:1:#content}\n"
        skipSleep=true
        ;;
      '@')
        macroStack+=$flag
        echo "${macros[$flag]}" |
        while read localLine; do
          useLine $localLine
        done
        macroStack+="-"
        skipSleep=true
        ;;
      'z')
        if [[ -z $content ]]; then
          lineSleep=$defaultLineSleep
        else
          lineSleep=$content
        fi
        skipSleep=true
        ;;
      '*')
        xdotool key --delay 20 $content
        ;;
      '#')
        sleep $content
        skipSleep=true
        ;;
      '.')
        case "$flag" in
          '.')
            xdotool type "$content"
            ;;
          *)
            xdotool type "$content" && xdotool key Return
            ;;
        esac
        ;;
      '+')
        xdotool mousemove $content

        if [ "$flag" = '.' ]; then
          xdotool click 1
        fi
        ;;
      *)
        if [[ ! -z $line ]]; then
          echo "unrecognized type '$type' at line '$line' at #$lineNo"
          echo "macro stack: $macroStack"
          notify "exiting from error. Run the command in a terminal to see output"
          exit 1
        else
          skipSleep=true
        fi
        ;;
    esac
    if [[ -z $skipSleep ]]; then
      sleep $lineSleep
    fi
  done
}
local title=$1

function ds {
  date +%s%1N
}
local startTime=$(ds)

function timeDiff {
  echo "$(bc -l <<< "scale=1; ($(ds) - $startTime)/10")s"
}
function notify {
  echo "notify: $1"
  notify-send "setup $title" "($(timeDiff)) $1"
}

notify "starting"
local lineNo=0
local defaultLineSleep=.4
local lineSleep=$defaultLineSleep

cat ~/.project-setups/$1 |
while read line; do
  ((lineNo++))
  useLine $line
done
notify "ended"
) &
