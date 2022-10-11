#!/usr/bin/env bash
#
#  Copyright 2022 mdfk <mdfk@Elite>

# Resources
icon_menu="../rasi/iconmenu.rasi"
list_menu="../rasi/listmenu.rasi"

# Options
active='-a 2,0'

add='' 
prev=''
next=''
list=''
end_task=""

# Functions
rofi_cmd() {
    if [ $1 == main ]; then
        rofi -p "Calendar" -mesg "$(echo -e "$message")" \
            -theme $icon_menu -dmenu $@ \
            -theme-str 'window { width: 290px; }' \
            -theme-str 'textbox-prompt-colon {str: "";}' \
            -theme-str 'message {padding: 5px 8px 5px 8px;}' \
            -theme-str 'textbox {horizontal-align: 0.5; vertical-align: 1; font: "Iosevka 18";}' \
            -theme-str "window {location: north;}" \
            -selected-row 2 \
            -theme-str 'element-text {padding: 0px 4px;}'
    else
        rofi -p "Calendar" -theme $icon_menu -dmenu $@ -mesg "$message" \
            -theme-str "window {location: north; width: 290px;}" \
            -theme-str 'textbox-prompt-colon {str: ""; }' \
            -theme-str 'textbox {horizontal-align: 0; }' \
            -theme-str 'textbox {font: "Iosevka 11"; }'
    fi
}

handle_action() {
	if [ "$DIFF" -ge 0 ]; then
      message=$(cal "+$DIFF months")
	else
      message=$(cal "$((-DIFF)) months ago")
	fi
}

main_menu() {
    DIFF=0
    options="$list\n$prev\n$add\n$next\n$end_task"
    message=$(cal)
    
    while true; do
        # Rofi command
        chosen="$(echo -e "$options" | rofi_cmd "main" $active $urgent)"
        
        sleep 0.1
        echo $chosen
        case $chosen in
#            $add)
#                ;;
            $next)
                DIFF=$((DIFF+1))
                echo next: $DIFF;;
            $prev)
                DIFF=$((DIFF-1))
                echo prev: $DIFF;;
            $list)
                info_menu;;
            *)
                exit
        esac
        handle_action
    done
}

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
