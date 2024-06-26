#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Bluetooth #######

# Functions
options() {
    	status=$(bluetoothctl show)
    	dev_now="$(bluetoothctl info | grep Name | cut -d ' ' -f 2-)"
    	dev_battery="$(bluetoothctl info | grep 'Battery Percentage'| awk '{print $(NF)}' | tr -d '()')"
    	dev_mac=$(bluetoothctl info | head -n 1 | cut -d ' ' -f 2)
    	dev_know=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)
	[ -n "$dev_now" ] && title="$dev_now" || title='Bluetooth'
	[ -n "$dev_battery" ] && message=$(echo -e " $dev_battery%")

    	# Function to check power, connection and others
    	# status_options <icon-on> <icon-off>
    	status_options  
}

device_connected() {
    device_info=$(bluetoothctl info "$dev_now")
    if echo "$device_info" | grep "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

handle_option() {
    # Switch connection
    if [ $1 == 'connection' ]; then
        # No device connected
        if [[ -z "$dev_now" ]]; then
            # check recent device disconnected
            if [[ -z "$dev_mac_tmp" ]]; then
                # Know devices menu
                element_list=$dev_know
                menu_list
            else
                dev_tmp=$(bluetoothctl connect $dev_mac_tmp)
                if [[ $dev_tmp =~ "Failed" ]]; then 
                    menu_list
                fi
            fi
        else
            bluetoothctl disconnect $dev_mac
            # Temp mac variable to reconnect
            dev_mac_tmp=$dev_mac
        fi
    # Switch power
    elif [ $1 == 'power' ]; then
        if [[ $status =~ "Powered: no" ]]; then
            bluetoothctl power on >/dev/null
        else
            bluetoothctl power off >/dev/null
        fi
    # Scan menu
    elif [ $1 == 'list' ]; then
        if [[ $status =~ 'Powered: yes' ]]; then
            notify-send -i bluetooth-connected -a "Bluetooth" "Scanning devices" -h string:x-dunst-stack-tag:'bluetooth' -t 10000
            bluetoothctl --timeout 10 scan on >/dev/null
            sleep 0.5

            element_list=$(bluetoothctl devices | cut -d ' ' -f 3-)
            dunstctl close
	    #list_menu='listmenu-entry.rasi'
            menu_list
        else
            notify-send -i bluetooth-poweron -a "Bluetooth" "Power up controller before!" -h string:x-dunst-stack-tag:'bluetooth'
        fi
    else
        exit
    fi
    main_menu
}

element_option() {
    if [[ -n "$chosen" ]]; then
        device=$(bluetoothctl devices | grep "$chosen" | cut -d ' ' -f 2)
	notify-send -i bluetooth-poweron -t 4000 -a "Bluetooth" "Connecting to: $chosen" -h string:x-dunst-stack-tag:'bluetooth'
	[[ ! "$chosen" =~ "$dev_know" ]] && bluetoothctl pair "$device" > /dev/null
        bluetoothctl connect "$device" > /dev/null
        dunstctl close
        if [[ `bluetoothctl info` =~ "Name: $chosen" ]]; then
	    notify-send -i bluetooth-poweron -t 4000 -a "Bluetooth" "Connected to: $chosen" -h string:x-dunst-stack-tag:'bluetooth'
            exit
        else
            message="<span color='#f7768e'>Error in connection</span>"
            menu_list
        fi
    fi
}

check_case() {
    case $chosen in
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
icon=''
icon_type='scan'
icon_current='know-alt'

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
