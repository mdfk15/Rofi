#!/usr/bin/env bash
#
#  Copyright 2022 mdfk <mdfk@Elite>

# Resources
icon_menu="../rasi/iconmenu.rasi"
list_menu="../rasi/listmenu.rasi"
know=$(nmcli connection show | awk '{print $1}')
nmcli -f SSID dev wifi | tail -n +2 | sed '/^--/d' > ~/.config/scripts/wifi_list & # SSID,BARS 

# Functions
status_options() {
    active=''
    urgent='-u 2,5'
    status=$(nmcli g)
    wireless=$(nmcli -t -f NAME c show --active)

    # Options
    if [[ $status =~ disable ]]; then
        [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
        power=''
    else
        [ -n "$active" ] && active+=",3" || active="-a 3"
        power=''
    fi
    if  [[ $status =~ disconnected ]]; then
        connection=''
        message='Disconnected'
        echo disconnected
    else
        [ -n "$active" ] && active+=",0" || active="-a 0"
        connection=''
        message="Connected to: $wireless"
    fi
    ####### PENDIENTEEEE #######
#    if [[ $firewall =~ "xxx" ]]; then
#        protection='' #
#    fi
    list='' #
    info=''
    protection=''
    cancel=""
}

toggle_option() {
    if [ $1 == connection ]; then
        if [[ $status =~ disconnected ]]; then
            nmcli dev connect wlp58s0
        else
            nmcli dev disconnect wlp58s0
        fi
    elif [ $1 == protection ]; then
        if [ $status =~ protection ]; then
            pass
        else
            pass
        fi
    elif [ $1 == list ]; then
        network_list $list_menu
    elif [ $1 == info ]; then
    ####### PENDIENTEEEE #######
        pass
        back=' '
        options="$back\n$cancel"
        
        # Rofi command
        chosen="$(echo -e "$options" | rofi_cmd 'info')"
        sleep 0.1
        case $chosen in
            $back)
                continue;;
            *)
                rm ~/.config/scripts/wifi_list
                exit;;
        esac
    else [ $1 == power ]
        if [[ $status =~ disabled ]]; then
            nmcli radio wifi on
        else
            nmcli radio wifi off
        fi
    fi
    main_menu $icon_menu
}

network_list() {
    while ! [ -s ~/.config/scripts/wifi_list ]; do
        sleep 0.2
    done 
    n=2
    active=''
    back=' Back'
    exit_opt=' Exit'
    options="$back\n$exit_opt\n$(cat ~/.config/scripts/wifi_list)"

    lines=$(cat ~/.config/scripts/wifi_list | wc -l)
    ((lines+=2))
    if [ $lines -gt 12 ]; then
        if ! [ $(($lines%2)) == 0 ]; then
            ((lines+=1))
        fi
        lines=$((lines/2))
    fi
    
    while read line; do
        echo $line
        if [[ $dev_name_list =~ $line ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        ((n+=1))
    done < <(echo -e "$2")

    chosen=$(echo -e "$options" | rofi_cmd $1 -u 0,1 $active -selected-row 2)
    sleep 0.1
    case $chosen in
        $back)
            continue;;
        $exit_opt)
            rm ~/.config/scripts/wifi_list
            exit;;
        *)
            if [[ -n $chosen ]]; then
                continue
    ####### PENDIENTEEEE #######
                #grep -q $chosen <<< $know && nmcli device wifi connect $chosen || connection=$(confirm_pass) & nmcli device wifi connect $chosen password $connection
            else
                exit
            fi
    esac
}

confirm_pass() {
        rofi -dmenu\
                -i\
                -no-fixed-num-lines\
                -p "Password: "\
                -theme ~/.config/rofi/confirm.rasi
}

rofi_cmd() {
    if [ $1 == $icon_menu ]; then
        rofi -p "Wireless" -theme $1 -dmenu $@ -mesg "$message" \
            -theme-str 'textbox-prompt-colon {str: ""; }'
    elif [ $1 ==  $list_menu ]; then
        rofi -p "Wireless" -theme $1 -dmenu $@ -mesg "$message" \
            -theme-str 'textbox-prompt-colon {str: ""; }' \
            -theme-str "listview {lines: $lines; }"
    else
        rofi -p "Wireless" -theme $icon_menu -dmenu $@ -mesg "$message" \
            -theme-str 'textbox-prompt-colon {str: ""; }' \
            -theme-str 'textbox {font: "Iosevka 11"; }'
    fi
}

main_menu() {
    status_options
    options="$connection\n$list\n$protection\n$power\n$info\n$cancel"
    
    # Rofi command
    chosen="$(echo -e "$options" | rofi_cmd $1 $active $urgent)"
    
    sleep 0.1
    case $chosen in
        $connection)
            toggle_option connection;;
        $list)
            toggle_option list;;
        $info)
            toggle_option info ;;
        $protection)
            toggle_option protection ;;
        $power)
            toggle_option power;;
        $cancel)
            rm ~/.config/scripts/wifi_list
            exit;;
        *)
            rm ~/.config/scripts/wifi_list
            exit
    esac
}

case $1 in
    --status)
        pass ;;
    *)
        main_menu $icon_menu;;
esac
rm ~/.config/scripts/wifi_list
