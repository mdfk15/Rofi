#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Powermenu #######

# Timer
timer=6

rofi_cmd() {
  rofi -p "Powermenu" -theme "~/.config/rasi/powermenu" -dmenu $@ \
    -mesg "Uptime `uptime -p | sed -e 's/up //g'`" \
    -hover-select -me-select-entry '' -me-accept-entry MousePrimary \
    $selected_row $urgent
}

# Options
shutdown=""
reboot=""
suspend=""
logout=""
lock=""

time_notify() {
  for N in $(seq $timer -1 1)
  do
    dunstify -u critical -a "Power system" "$1 in $(($N)) Click to cancel!!!" -h string:x-dunst-stack-tag:"$1" --action="replyAction,reply" > $path/pm_forward &
    sleep 1
	  if grep -Fxq 2 $path/pm_forward; then
	  	killall sh
 	  fi
  done
}

# Variable passed to rofi
options="$shutdown\n$reboot\n$suspend\n$logout\n$lock"

n=0
for i in $(echo -e "$options"); do
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
    $lock)
      dm-tool switch-to-greeter;;
    $cancel) ;;
esac
rm ~/.config/scripts/pm_forward
