#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Powermenu #######

# Timer
path=~/.cache
timer=6

rofi_cmd() {
  rofi -p "Powermenu" -theme vertical -dmenu $@ \
    -mesg "$message" \
    -hover-select -me-select-entry '' -me-accept-entry MousePrimary \
    -theme-str "listview { lines : $lines; }" \
    $urgent
}

# Options
shutdown=""
reboot=""
suspend=""
logout=""
lock=""
uptime=""

time_notify() {
  for N in $(seq $timer -1 1)
  do
	  notify-send -u critical -i powermgr -a "$1 in $(($N))" "Click this notify to cancel!" -r 34420 --action="replyAction,reply" > $path/pm_forward &
	  sleep 1
	  if grep -Fxq 2 $path/pm_forward; then
	  	killall sh
 	  fi
  done
}

message=$(echo -e "$(uptime -p | sed -e 's/up //g' -e 's/ hours/h/' -e 's/ days/d/' -e 's/ minutes/m/' -e 's/, /\\n/')")

# Variable passed to rofi
options="$shutdown\n$reboot\n$suspend\n$logout\n$lock"

n=0
for i in $(echo -e "$options"); do
  [[ "$i" == "$cancel" ]] && urgent="-u $n"
  [[ "$i" == "$shutdown" ]] && selected_row="-selected-row $n"
  ((n+=1))
done
lines=$n
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
    $lock)
      dm-tool switch-to-greeter;;
    $cancel) ;;
esac
rm ~/.config/scripts/pm_forward
