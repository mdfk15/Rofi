#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Wifi #######

# Functions
options() {
	title='Wireless'
	icon=''
    	status=$(nmcli g)
    	current=$(nmcli -t -f NAME c show --active | grep -v lo)

    	# Function to check power, connection and others
    	# Arg1 <icon-on> Arg2 <icon-offve>
    	status_options  
}

scanning_opt() {
        notify-send -i "$icon_name" -a "Wireless" "Scanning networks" -t 10000 -h string:x-dunst-stack-tag:"$title"
        nmcli -f SSID dev wifi | tail -n +2 | sed '/^--/d' > $path/wifi_list # SSID,BARS 

        # List variable pased to Rofi
        element_list="$(cat $path/wifi_list)"
	title='Scan list'
}

handle_option() {
    if [ $1 == 'connection' ]; then
        if [[ $status =~ disconnected ]]; then
            nmcli dev connect wlp58s0 >/dev/null
            sleep 1
        else
            nmcli dev disconnect wlp58s0 >/dev/null
        fi
    elif [ $1 == 'list' ]; then
	scanning_opt

        #element_list=" Rescan\n$(cat $path/wifi_list)"
	#urgent='-u 0,1,2'
	#selected_row='3'
        rm $path/wifi_list

        # Rofi list menu function.
        dunstctl close
        menu_list
    elif [ $1 == 'power' ]; then
        if [[ $status =~ disabled ]]; then
            nmcli radio wifi on >/dev/null
            sleep 3
        else
            nmcli radio wifi off >/dev/null
        fi
    else
        exit
    fi
    main_menu
}

element_option() {
	net_ssid=$(echo "$chosen" | xargs)
	[ -n "$net_ssid" ] || exit 
	if [[ "$know" =~ "$net_ssid" ]]; then
		notify-send -i "$icon_name" -a "Wireless" "Connecting to $net_ssid" -t 100000 -h string:x-dunst-stack-tag:"$title"
    	    	nmcli device wifi connect "$net_ssid" && notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 4000 -h string:x-dunst-stack-tag:"$title"
    	#elif [[ "$chosen" =~ "Rescan" ]]; then
	#	nmcli d wifi rescan
	#	sleep 2
	#	scanning_opt
    	else
    	    passphrase=$(confirm_pass)
    	    if [[ -n "$passphrase" ]]; then
		notify-send -i "$icon_name" -a "Wireless" "Connecting to $net_ssid" -t 100000 -h string:x-dunst-stack-tag:"$title"
		connection_err=$((nmcli device wifi connect "$net_ssid" password "$passphrase") 2>&1) && notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 4000 -h string:x-dunst-stack-tag:"$title"
    	    else
    	        message="<span color='#f7768e'>Error, empty input</span>"
    	        menu_list
    	    fi
    	fi
	sleep 0.5
	dunstctl close
	if ! [[ "$(nmcli -t -f NAME c show --active)" =~ "$net_ssid" ]]; then
    	        message="<span color='#f7768e'>Error ${connection_err##*:}</span>"
    	        menu_list
	else
		notify-send -i "$icon_name" -a "Wireless" "Connected to $net_ssid" -t 10000 -h string:x-dunst-stack-tag:"$title"
		exit 0
    	fi
}

confirm_pass() {
    rofi -dmenu\
        -i\
        -no-fixed-num-lines\
	-password\
        -p "Wireless"\
        -mesg "Connecting to: $chosen" \
        -theme ~/.config/rofi/confirm.rasi
}

check_case() {
    case "$chosen" in
        $connection)
            handle_option 'connection';;
        $list)                     
            handle_option 'list';; 
        $power)                    
            handle_option 'power';; 
        $cancel)
            exit;;
        *)
            exit;;
    esac
}

# Resources
icon_name='wifi-high'	# Notification
icon_type='wifi'	# Listview icon
icon_current="know-alt"

# Lists
know=$(nmcli -f NAME connection show)

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
