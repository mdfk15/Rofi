#!/usr/bin/env bash
#
#  Copyright 2022 mdfk <mdfk@Elite>

# Resources
icon_menu="../rasi/iconmenu.rasi"
list_menu="../rasi/listmenu.rasi"

# Functions
status_options() {
    active='-a 2,0'
    urgent='-u 5'
    status=$(mpc)

    # Options
    if [[ $status =~ "playing" ]]; then
        [ -n "$active" ] && active+=",2" || active="-a 2"
        play=''
    else
        play=''
    fi
    if [[ $status =~ "playing" ]]; then
        random=""
        [ -n "$active" ] && active+=",2" || active="-a 2"
    else
        random=""
    fi


    if [[ $status =~ "playing" ]]; then
        list='' #
        [ -n "$active" ] && active+=",2" || active="-a 2"
    else
        list='' #
    fi
    prev=''
    next=''
    cancel=""
}

music_list() {
    list_music="$(mpc --format '%title%' playlist)"
    n=2
    active=''
    back=' Back'
    exit_opt=' Exit'
    options="$back\n$exit_opt\n$list_music"

    lines=$(echo "$list_music" | wc -l)
    ((lines+=2))
    if [ $lines -gt 12 ]; then
        if ! [ $(($lines%2)) == 0 ]; then
            ((lines+=1))
        fi
        lines=$((lines/2))
    fi
    
    while read line; do
        current_song=$(mpc --format '%title%' current)
        if [[ $current_song == $line ]]; then
            [ -n "$active" ] && active+=",$n" || active="-a $n"
        fi
        ((n+=1))
    done < <(echo -e "$list_music")

    chosen=$(echo -e "$options" | rofi_cmd $1 -u 0,1 $active -selected-row 2)

    sleep 0.1
    case $chosen in
        $back)
            main_menu $icon_menu;;
        $exit_opt)
            exit;;
        *)
            n=1
            while read line; do
                if [[ $chosen == $line && -n $chosen ]]; then
                    mpc play $n
                elif [ -z $chosen ]; then
                    exit
                fi
                ((n+=1))
            done < <(echo -e "$list_music")
    esac
    music_list $list_menu
}

rofi_cmd() {
    rofi -p "Music" -mesg "$message" \
        -theme $1 -dmenu $@ \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -theme-str "window {location: north;}" \
        -selected-row 2 
}


main_menu() {
    status_options
    options="$random\n$prev\n$play\n$next\n$list\n$cancel"
    message=$(mpc --format "%title% \n%artist% - %album%" current)
    echo $message
    
    # Rofi command
    chosen="$(echo -e "$options" | rofi_cmd $1 $active $urgent)"
    
    sleep 0.1
    case $chosen in
        $play)
            mpc toggle
            ;;
        $prev)
            mpc prev
            ;;
        $next)
            mpc next
            ;;
        $list)
            music_list $list_menu
            ;;
        $random)
            mpc prev
            ;;
        $cancel)
            exit;;
        *)
            exit;;
    esac
    main_menu $icon_menu
}

case $1 in
    --status)
        pass ;;
    *)
        main_menu $icon_menu;;
esac
