#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Volume #######

# Icons
mic_on=''
mic_off=''
muted=''
party='' #       
child=''
cancel=''

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
    if [[ "$state" =~ off ]]; then
        [ -n "$urgent" ] && urgent+=",3" || urgent="-u 3"
    fi
    if [[ "$mic_state" == off ]]; then
        mic="$mic_off"
    else
        mic="$mic_on"
    fi

    # Rofi variables
    options="$child\n$party\n$mic\n$muted"
    message=$(echo -e "Volume: $percentage\nPower: $state")

    n=0
    for i in $(echo -e "$options"); do
        #if [[ "$i" == "$child" ]] || [[ "$i" == "$party" ]]; then
        #    [ -n "$active" ] && active+=",$n" || active="-a $n"
        #fi

        #if [[ "$i" == "$cancel" ]]; then
        #    [ -n "$urgent" ] && urgent+=",$n" || urgent="-u $n"
        #fi

        if [[ "$i" == "$mic_on" ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        if [[ "$i" == "$party" ]] && [[ $percentage > 50% ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        
        if [[ "$i" == "$child" ]] && [[ $percentage < 51% ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        if [[ "$i" == "$volume_on" ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi

        ((n+=1))
    done
}

handle_option() {
    if [ $1 == 'muted' ]; then
        amixer set Master toggle >/dev/null
    elif [ $1 == 'party' ]; then
        notify-send -a "Volume" "Inc: 70%" \
		-i '~/.icons/volume-inc.png' \
		-h string:x-dunst-stack-tag:'volume' \
 		-h 'int:value:70' 
        amixer set Master 70% >/dev/null
    elif [ $1 == 'child' ]; then
        notify-send -a "Volume" "Inc: 30%" \
		-i '~/.icons/volume-dec.png' \
		-h string:x-dunst-stack-tag:'volume' \
 		-h 'int:value:30' 
        amixer set Master 30% >/dev/null
    elif [ $1 == 'mic' ]; then
        amixer set Capture toggle >/dev/null
    else
        exit
    fi
}

check_case() {
    case $chosen in
        $muted)
            handle_option 'muted';;
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
