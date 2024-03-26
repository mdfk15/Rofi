#!/usr/bin/env bash

## Author  : Aditya Shakya (adi1090x)
## Github  : @adi1090x
#
## Applets : Battery

# Import Current Theme
#source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="/home/mdfk/.config/rofi/iconmenu.rasi"

# Battery Info
battery_device="`upower -e | grep BAT`"
battery="`upower -i $battery_device | grep native-path | awk -F: '{print $2}' | xargs`"
battery_status="`upower -i $battery_device | grep state | awk -F: '{print $2}' | xargs`"
percentage="`upower -i $battery_device | grep percentage | awk -F: '{print $2}' | xargs`"
time="`upower -i $battery_device | grep -E 'time to empty|time to full' | awk -F: '{print $2}' | xargs`"

if [[ -z "$time" ]]; then
	time=' Fully Charged'
fi

# Theme Elements
prompt="$battery_status"
mesg="${battery}: ${percentage}, ${time}"

if [[ "$theme" == *'iconmenu'* ]]; then
	list_col='6'
	list_row='1'
	win_width='400px'
elif [[ "$theme" == *'listmenu'* ]]; then
	list_col='4'
	list_row='1'
	win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
	list_col='1'
	list_row='4'
	win_width='500px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
	list_col='4'
	list_row='1'
	win_width='550px'
fi

# Charging Status
active=""
urgent=""
if [[ $battery_status = *"charging"* ]]; then
    active="-a 1"
    ICON_CHRG=""
elif [[ $battery_status = *"full"* ]]; then
    active="-u 1"
    ICON_CHRG=""
else
    urgent="-u 1"
    ICON_CHRG=""
fi

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

# Options
layout=`cat ${theme} | grep 'USE_ICON' | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
	option_1=" $battery_status"
	option_2=" Power Manager"
	option_3=" Diagnose"
else
	option_1="$ICON_CHRG"
	option_2=""
	option_3=""
fi

# Rofi CMD
rofi_cmd() {
	rofi -theme-str "window {width: $win_width;}" \
		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
		-theme-str "textbox-prompt-colon {str: \"$ICON_DISCHRG\";}" \
		-dmenu \
		-p "$prompt" \
		-mesg "$mesg" \
		${active} ${urgent} \
		-markup-rows \
		-theme iconmenu
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$option_1\n$option_2\n$option_3" | rofi_cmd
}

# Execute Command
run_cmd() {
	polkit_cmd="pkexec env PATH=$PATH DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY"
	if [[ "$1" == '--opt1' ]]; then
		notify-send -u low "$ICON_CHRG Status : $battery_status"
	elif [[ "$1" == '--opt2' ]]; then
		xfce4-power-manager-settings
	elif [[ "$1" == '--opt3' ]]; then
		${polkit_cmd} alacritty -e powertop
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $option_1)
		run_cmd --opt1
        ;;
    $option_2)
		run_cmd --opt3
        ;;
    $option_3)
		run_cmd --opt4
        ;;
esac


