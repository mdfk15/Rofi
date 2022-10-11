#!/usr/bin/env bash
#
#  Copyright 2022 mdfk <mdfk@Elite>

main="../rasi/iconmenu.rasi"
message=$(uptime -p | sed -e 's/up //g')

rofi_cmd() {
  rofi -p "Powermenu" -theme $1 -dmenu $@ \
    -mesg "Uptime: `uptime -p | sed -e 's/up //g'`  - off 7s" \
    -theme-str 'textbox-prompt-colon {str: ""; }' \
    $selected_row $urgent
     }

# Options
shutdown=""
reboot=""
suspend=""
logout=""
cancel=""

time_notify() {
  for N in $(seq 7)
  do
    dunstify -u critical -a "Power system" "$1 in $((8-$N)) Click to cancel!!!" -h string:x-dunst-stack-tag:"$1" --action="replyAction,reply" > ~/.config/scripts/pm_forward &
    sleep 1
	  if grep -Fxq 2 ~/.config/scripts/pm_forward
 	  then 
	  	killall sh
 	  else
 	  	echo "nada"
 	  fi
  done
}

# Variable passed to rofi
options="$shutdown\n$reboot\n$suspend\n$logout\n$cancel"
n=0
for i in $(echo -e "$options"); do
  echo $i
  echo $n
  [[ "$i" == "$cancel" ]] && urgent="-u $n"
  [[ "$i" == "$shutdown" ]] && selected_row="-selected-row $n"
  ((n+=1))
done
chosen="$(echo -e "$options" | rofi_cmd $main)"

case $chosen in
    $shutdown)
      time_notify "poweroff"
      systemctl poweroff -i ;;
    $reboot)
      time_notify "reboot"
      systemctl reboot ;;
    $suspend)
      time_notify "suspend"
      kill $(pgrep -f "Power system suspend in 1 Click to cancel!!!")
      systemctl suspend ;;
    $logout)
      time_notify "poweroff"
      pkill -KILL -u $(whoami) ;;
    $cancel) ;;
esac
rm ~/.config/scripts/pm_forward
