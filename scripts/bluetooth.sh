#!/usr/bin/env bash
#
#  Copyright 2022 mdfk <mdfk@Elite>

# Resources
icon_menu="../rasi/iconmenu.rasi"
list_menu="../rasi/listmenu.rasi"

# Functions
status_options() {
    active=''
    urgent='-u 5'
    status=$(bluetoothctl show)
    dev_now="$(bluetoothctl info | grep Name | cut -d ' ' -f 2-)"
    dev_mac=$(bluetoothctl info | head -n 1 | cut -d ' ' -f 2)
    dev_name_list=$(bluetoothctl devices | grep Device | cut -d ' ' -f 3-)

    # Options
    if [[ $status =~ "Powered: no" ]]; then
        [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
        power=''
    else
        [ -n "$active" ] && active+=",3" || active="-a 3"
        power=''
    fi
    if [ -z "$dev_now" ]; then
        message="Disconnect"
        connection=''
    else 
        message="Connected to $dev_now" 
        connection='' #
        [ -z $active ] && active='-a 0,3' || active+=",0"
    fi

    list='' #
    share=''
    info=''
    cancel=""
}

device_connected() {
    device_info=$(bluetoothctl info "$dev_now")
    if echo "$device_info" | grep "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

toggle_option() {
    if [ $1 == connection ]; then
        if [[ -z $dev_now ]]; then
            if [[ -z $dev_mac_tmp ]]; then
                dev_list $list_menu "$dev_name_list"
            else
                dev_tmp=$(bluetoothctl connect $dev_mac_tmp)
                if [[ $dev_tmp =~ "Failed" ]]; then 
                    dev_list $list_menu "$dev_name_list"
                fi
            fi
        else
            bluetoothctl disconnect $dev_mac
            dev_mac_tmp=$dev_mac
        fi
    elif [ $1 == power ]; then
        if [[ $status =~ "Powered: no" ]]; then
            bluetoothctl power on
        else
            bluetoothctl power off
        fi
    else [ $1 == list ]
        if [ $power == '' ]; then
            bluetoothctl scan on &
            sleep 5
            kill $(pgrep -f "bluetoothctl scan on")
            sleep 0.5
            dev_scan_list=$(bluetoothctl devices | cut -d ' ' -f 3-)
            dev_list $list_menu "$dev_scan_list"
        fi
    fi
    main_menu $icon_menu
}

dev_list() {
    n=2
    active=''
    back=' Back'
    exit_opt=' Exit'
    options="$back\n$exit_opt\n$2"

    lines=$(echo -e "$2" | wc -l)
    ((lines+=2))
    if [ $lines -gt 12 ]; then
        if ! [ $(($lines%2)) == 0 ]; then
            ((lines+=1))
        fi
        lines=$((lines/2))
    fi
    
    while read line; do
        if [[ $dev_name_list =~ $line ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        ((n+=1))
    done < <(echo -e "$2")

    chosen="$(echo -e "$options" | rofi_cmd $1 -u 0,1 $active $lines -selected-row 2)"
    case $chosen in
        $back)
            continue;;
        $exit_opt)
            exit;;
        *)
            if [[ -n $chosen ]]; then
                device=$(bluetoothctl devices | grep "$chosen" | cut -d ' ' -f 2)
                bluetoothctl connect $device
            else
                exit
            fi
    esac
}

rofi_cmd() {
    if [ $1 == $icon_menu ]; then
        rofi -p "Bluetooth" -theme $1 -dmenu $@ -mesg "$message" \
            -theme-str 'textbox-prompt-colon {str: ""; }'
    else
        rofi -p "Bluetooth" -theme $1 -dmenu $@ -mesg "$message" \
            -theme-str 'textbox-prompt-colon {str: ""; }' \
            -theme-str "listview {lines: $lines; }"
    fi
}

main_menu() {
    status_options
    options="$connection\n$list\n$share\n$power\n$info\n$cancel"
    
    # Rofi command
    chosen="$(echo -e "$options" | rofi_cmd $1 $active $urgent)"
    
    sleep 0.1
    case $chosen in
        $connection)
            toggle_option connection;;
        $list)
            toggle_option list;;
#        $info)
#            ;;
        $power)
            toggle_option power;;
        $cancel)
            exit;;
        " Back")
            main_menu $icon_menu
    esac
}

case $1 in
    --status)
        pass ;;
    *)
        main_menu $icon_menu;;
esac
