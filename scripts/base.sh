#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Base scripts #######

# Rofi themes
icon_menu="iconmenu.rasi"
list_menu="listmenu.rasi"

# Functions
status_options() {
    # Rofi status elements
    active=''
    urgent=''

    # Options
    ## power
    if [[ "$status" =~ disable ]] || [[ "$status" =~ 'Powered: no' ]] ; then
        #[ -n "$urgent" ] && urgent+=",2" || urgent="-u 2"
        power=''
    	options="$power"
	message='Poweroff'
    else
        [ -n "$active" ] && active+=",2" || active="-u 2"
        power=''

	## connection
	if  [[ $status =~ full ]] || [[ -n "$dev_now" ]] ; then
	    [ -n "$active" ] && active+=",0" || active="-a 0"
	    [ -n "$current" ] && [ -z "$message" ] && message="Connected to: $current" || message="Connected to: $current_dev"
	    connection=$1
	else
	    message='Disconnected'
	    connection=$2
	fi

	list=''
	cancel=""

    	options="$connection\n$list\n$power"
    fi
    
}

rofi_cmd() {
    if [ $1 == 'icon' ]; then
	    rofi -p "$title" -theme $icon_menu -dmenu $extra_opt \
                -mesg "$message" $active $urgent \
                -theme-str "textbox-prompt-colon {str: \"$icon\"; }" \
                -theme-str "window {$window_opt}" \
                -theme-str "coverbox {$cover_opt}" \
                -theme-str "inputbar {$inputbar_opt}" \
                -theme-str "textbox {$message_opt}"
    elif [ $1 ==  'list' ]; then
	    [ -z "$selected_row" ] && selected_row='1'
	    rofi -p "$title" -theme $list_menu -dmenu \
		-mesg "$message" $active $urgent \
		-i \
        	-selected-row "$selected_row" \
        	-theme-str "textbox-prompt-colon {str: \"$icon\"; }" \
        	-theme-str "listview {lines: $lines; }" \
        	-theme-str "inputbar {$inputbar_opt}" \
        	-theme-str "window {$window_opt}" \
        	-theme-str "coverbox {$cover_opt}" \
        	-theme-str "textbox {$message_opt}"
    fi
}

menu_list() {
    	# Rofi variables
    	active=''
    	urgent="-u 0"

    	# Menu options
    	back='Back\0icon\x1fback-user'
    	exit_opt='Exit\0icon\x1fexit-user'

    	# Lines count
    	[ -n "$element_list" ] && lines=$(echo -e "$element_list" | wc -l)
    	((lines+=1))
    	if [ $lines -gt 12 ]; then
		lines=12
    	    #if ! [ $(($lines%2)) == 0 ]; then
    	    #    ((lines+=1))
    	    #fi
    	    #lines=$((lines/2))
    	fi
    	
    	n=1
    	while read line; do
    	    if [[ "$current" == "$line" ]] || [[ "$dev_now" == "$line" ]]; then
    	        [ -n "$active" ] && active+=",$n" || active="-a $n"
		#elements+="$line\0icon\x1f$icon_current\n"
		elements+="${line%:*}\0icon\x1f$icon_current\x1fmeta\x1f${line#*:}\n"
	    else
		elements+="${line%:*}\0icon\x1f$icon_type\x1fmeta\x1f${line#*:}\n"
		#elements+="$line\0icon\x1f$icon_type\n"
    	    fi
    	    ((n+=1))
    	done < <(echo -e "$element_list")

    	options="$back\n$elements"

    	# Rofi command
    	chosen=$(echo -en "$options" | rofi_cmd 'list')
    	sleep 0.2
	[ -z "$chosen" ] && exit
    	case "$chosen" in
    	    'Back')
		    message='';;
    	    'Exit')
		    exit 0;;
    	    *)
		    elements=''
		    element_option "$chosen";;
    	esac
}

main_menu() {
    # Options
    options
    
    # Rofi command
    chosen="$(echo -e "$options" | rofi_cmd 'icon')"
    
    sleep 0.2
    [ -n "$chosen" ] && check_case
}
