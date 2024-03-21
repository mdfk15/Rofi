#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Calendar #######

options() {
    # Options
    active='-a 1'
    urgent=''
    window_opt="location: north; width:320px;"
    message_opt="font: \"Iosevka 19\";"
    extra_opt="-selected-row 1"

    prev=''
    next=''
    list=''

    # Rofi variables
    options="$prev\n$list\n$next"
}


info_menu() {
    back=''
    exit_opt=''
    options="$back\n$exit_opt"
    active='-a 0'
    urgent='-u -1'
    message=$(cat ~/task/calendar_tasks)
    message_opt="font: \"Iosevka 13\"; horizontal-align: 0;"
    chosen=$(echo -e "$options" | rofi_cmd 'info')

    case $chosen in
        $back)
            message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")
            main_menu $icon_menu;;
        *)
            exit;;
    esac
}

handle_action() {
	if [ "$DIFF" -ge 0 ]; then
      		message=$(cal "+$DIFF months")
	else
      		message=$(cal "$((-DIFF)) months ago")
	fi
}

check_case() {
    case $chosen in
        $next)
            DIFF=$((DIFF+1))
            handle_action;;
        $prev)
            DIFF=$((DIFF-1))
            handle_action;;
        $list)
            info_menu;;
        *)
            exit
    esac
    today_check
    main_menu
}

today_check() {
	if [[ "$message" =~ "$CURRENT_MONTH" ]]; then
		message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")
	fi
}

# Resources
path=$(dirname "$0")
source $path/base.sh

DIFF=0
TODAY=$(date '+%-d')
CURRENT_MONTH=$(cal | head -1)
message=$(cal | sed -z "s|\s$TODAY\s| <u><b>$TODAY</b></u> |1")

title='Calendar'
icon=''
icon_menu='calendar.rasi'

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
