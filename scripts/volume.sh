#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Volume #######

# Status
options() {
    # Status
    percentage="`amixer sget Master| grep Left: | awk -F '[][]' '{ print $2 }'`"
    state="`amixer sget Master | grep Left: | awk -F '[][]' '{ print $4 }'`"
    mic_state="`amixer get Capture | grep Left: | awk -F '[][]' '{ print $4 }'`"

    # Options
    urgent=''
    active=''

    # Option icons: 
    if [[ $state =~ off ]]; then
        volume=''
        [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
    else
        volume=''
        [ -n "$active" ] && active+=",3" || active="-a 3"
    fi
    if [[ $mic_state =~ off ]]; then
        mic=''
    else
        mic=''
    fi

    party='' #
    child=''
    cancel=''

    # Rofi variables
    options="$child\n$party\n$mic\n$volume\n$cancel"
    message="Volume at $percentage - $state"

    n=0
    for i in $(echo -e "$options"); do
        if [[ "$i" == "" ]] || [[ "$i" == "" ]] || [[ "$i" == "" ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        if [[ "$i" == "$cancel" ]]; then
            [ -n "$urgent" ] && urgent+=",$n" || urgent="-u $n"
        fi

        if [[ "$i" == "" ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        if [[ "$i" == "$party" ]] && [[ $percentage > 50% ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        
        if [[ "$i" == "$child" ]] && [[ $percentage < 51% ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        ((n+=1))
    done
}

handle_option() {
    if [ $1 == 'volume' ]; then
        amixer set Master toggle >/dev/null
    elif [ $1 == 'party' ]; then
        dunstify -a "Volume" "Inc: 70%" \
		-i '~/.icons/volume-inc.png' \
		-h string:x-dunst-stack-tag:'volume'
        amixer set Master 70% >/dev/null
    elif [ $1 == 'child' ]; then
        dunstify -a "Volume" "Inc: 30%" \
		-i '~/.icons/volume-dec.png' \
		-h string:x-dunst-stack-tag:'volume'
        amixer set Master 30% >/dev/null
    elif [ $1 == 'mic' ]; then
        amixer set Capture toggle >/dev/null
    else
        exit
    fi
    main_menu
}

check_case() {
    case $chosen in
        $volume)
            handle_option 'volume';;
        $child)
            handle_option 'child';;
        $party)
            handle_option 'party';;
        $mic)
            handle_option 'mic';;
        $cancel)
            exit;;
        *)
            exit;;
    esac
    main_menu
}

# Resources
title='Volume'
icon=''

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
