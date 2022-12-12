#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Base scripts #######

# Rofi themes
icon_menu="../rasi/iconmenu.rasi"
list_menu="../rasi/listmenu.rasi"

# Defaults
element_list="1\n2"

# Functions
status_options() {
    # Rofi status elements
    active=''
    urgent='-u -1'

    # Options
    ## power
    if [[ $status =~ disable ]] || [[ $status =~ 'Powered: no' ]] ; then
        [ -n "$urgent" ] && urgent+=",2" || urgent="-u 2"
        power='' #
    else
        [ -n "$active" ] && active+=",2" || active="-a 2"
        power=''
    fi
    
    ## connection
    if  [[ $status =~ full ]] || [[ -n "$dev_now" ]] ; then
        [ -n "$active" ] && active+=",0" || active="-a 0"
        [ -n "$current" ] && message="Connected to: $current" || message="Connected to: $dev_now"
        connection=$1
    else
        message='Disconnected'
        connection=$2
    fi

    list='' #
    cancel=""

    options="$connection\n$list\n$power\n$cancel"
}

rofi_cmd() {
    if [ $1 == 'icon' ]; then
        rofi -p "$title" -theme $icon_menu -dmenu $extra_opt \
            -mesg "$message" $active $urgent $3 \
            -hover-select \
            -me-select-entry '' -me-accept-entry MousePrimary \
            -theme-str "textbox-prompt-colon {str: \"$icon\"; }" \
            -theme-str "inputbar {$inputbar_opt}" \
            -theme-str "window {$window_opt}" \
            -theme-str "textbox {$message_opt}"
    elif [ $1 ==  'list' ]; then
        rofi -p "$title" -theme $list_menu -dmenu \
            -mesg "$message" $active $urgent $3 \
            -scroll-method 1 \
            -selected-row 2 \
            -me-select-entry '' -me-accept-entry MousePrimary \
            -theme-str "textbox-prompt-colon {str: \"$icon\"; }" \
            -theme-str "listview {lines: $lines; $listview_opt}" \
            -theme-str "inputbar {$inputbar_opt}" \
            -theme-str "window {$window_opt}" \
            -theme-str "textbox {$message_opt}"
    fi
}

menu_list() {
    # Rofi variables
    active=''
    urgent='-u 0,1'

    # Menu options
    back=' Back'
    exit_opt=' Exit'
    options="$back\n$exit_opt\n$element_list"

    # Lines count
    n=2
    lines=$(echo -e "$element_list" | wc -l)
    ((lines+=2))
    if [ $lines -gt 12 ]; then
        if ! [ $(($lines%2)) == 0 ]; then
            ((lines+=1))
        fi
        lines=$((lines/2))
    fi
    
    while read line; do
        if [[ $current =~ $line ]] || [[ $dev_know =~ $line ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        ((n+=1))
    done < <(echo -e "$element_list")

    # Rofi command
    chosen=$(echo -e "$options" | rofi_cmd 'list' $@)
    sleep 0.2
    case $chosen in
        $back)
            continue;;
        $exit_opt)
            exit;;
        *)
            [ -z $chosen ] && exit
            element_option;;
    esac
}

main_menu() {
    # Options
    options
    
    # Rofi command
    chosen="$(echo -e "$options" | rofi_cmd 'icon')"
    
    sleep 0.2
    check_case
}
