#!/usr/bin/env bash

## Author  : mdfk@Elite <2024>
## Github  : @mdfk15
#
## Applets : Battery
#

options() {
	# Battery Info
	battery_device="`upower -e | grep BAT`"
	battery="`upower -i $battery_device | grep native-path | awk -F: '{print $2}' | xargs`"
	battery_status="`upower -i $battery_device | grep state | awk -F: '{print $2}' | xargs`"
	percentage="`upower -i $battery_device | grep percentage | awk -F: '{print $2}' | xargs`"
	time="`upower -i $battery_device | grep -E 'time to empty|time to full' | awk -F: '{print $2}' | sed -e 's/ minutes\| minute/m/; s/ hours\| hour/h/' | xargs`"

	# Discharging
	if [[ ${percentage%\%*} -ge 5 ]] && [[ ${percentage%\%*} -le 19 ]]; then
	    ICON_DISCHRG=""
	elif [[ ${percentage%\%*} -ge 20 ]] && [[ ${percentage%\%*} -le 39 ]]; then
	    ICON_DISCHRG=""
	elif [[ ${percentage%\%*} -ge 40 ]] && [[ ${percentage%\%*} -le 59 ]]; then
	    ICON_DISCHRG=""
	elif [[ ${percentage%\%*} -ge 60 ]] && [[ ${percentage%\%*} -le 79 ]]; then
	    ICON_DISCHRG=""
	elif [[ ${percentage%\%*} -ge 80 ]] && [[ ${percentage%\%*} -le 100 ]]; then
	    ICON_DISCHRG=""
	fi
	
	# Charging Status
	active=""
	urgent=""
	if [[ $battery_status = *"charging"* ]]; then
	    active="-a 1"
	    ICON_CHRG=""
	    ICON=''
	elif [[ $battery_status = *"full"* ]]; then
	    active="-u 1"
	    ICON_CHRG=""
	else
	    urgent="-u 1"
	    ICON_CHRG=""
	    ICON=''
	fi

	option_1="$ICON_CHRG"
	option_2=""
	option_3=""

	title="$battery_status"
	icon=$ICON
	options="$option_1\n$option_2\n$option_3"
	message=$(echo -e "$ICON ${percentage}\n${time}")
}

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

run_cmd() {
	polkit_cmd="pkexec env PATH=$PATH DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY"
	if [[ "$1" == '--opt1' ]]; then
		notify-send -u low "$ICON_CHRG Status : $battery_status"
	elif [[ "$1" == '--opt2' ]]; then
		xfce4-power-manager-settings
	elif [[ "$1" == '--opt3' ]]; then
		${polkit_cmd} alacritty -e htop
	fi
}

check_case() {
	case ${chosen} in
	    $option_1)
			run_cmd --opt1
	        ;;
	    $option_2)
			run_cmd --opt2
	        ;;
	    $option_3)
			run_cmd --opt3
	        ;;
	esac
}

path=$(dirname "$0")
source $path/base.sh

# Paramenters
icon_menu='vertical.rasi'
message_opt='font:"JetBrains Mono Nerd Font 12";'
window_opt='location : northeast; y-offset : 50px; x-offset : -30px;'

# Timer
timer=6

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
