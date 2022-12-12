#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Wifi #######

# Functions
options() {
    status=$(nmcli g)
    current=$(nmcli -t -f NAME c show --active)

    # Function to check power, connection and others
    # Arg1 <icon-on> Arg2 <icon-off>
    status_options  
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
        dunstify -a "Wireless" "Scanning networks" -t 4000 -h string:x-dunst-stack-tag:'wireless'
        nmcli -f SSID dev wifi | tail -n +2 | sed '/^--/d' > $path/wifi_list & # SSID,BARS 
        # Loop to check empty list
        while ! [ -s $path/wifi_list ]; do
            sleep 0.2
        done 

        # List variable pased to Rofi
        element_list="$(cat $path/wifi_list)"
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
    if [[ $know =~ $chosen ]]; then
        nmcli device wifi connect $chosen
    else
        passphrase=$(confirm_pass)
        if [[ -n $passphrase ]]; then
            nmcli device wifi connect $chosen password $passphrase & dunstify -a "Wireless" "Connecting to $chosen" -t 4000 -h string:x-dunst-stack-tag:'wireless'
            sleep 4
            dunstctl close
            if [[ `nmcli` =~ "connected to $chosen" ]]; then
                continue
            else
                message="<span color='#f7768e'>Error in connection</span>"
                menu_list
            fi
        else
            message="<span color='#f7768e'>Error, empty input</span>"
            menu_list
        fi
    fi
}

confirm_pass() {
    rofi -dmenu\
        -i\
        -no-fixed-num-lines\
        -p "Wireless"\
        -mesg "Connecting to: $chosen" \
        -theme ~/.config/rofi/confirm.rasi
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
    main_menu
}

# Resources
title='Wireless'
icon=''

# Lists
know=$(nmcli connection show | awk '{print $1}')

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
