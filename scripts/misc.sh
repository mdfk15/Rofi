#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Musictl #######

# Functions
options() {
    dunstctl close
    status=$(mpc)
    cover='129px' # Cover art images size
    artist=$(mpc --format '%albumartist%' current)
    album=$(mpc --format '%album%' current)

    # Check if file exist, if not it set a default cover image
    test -f ~/Musica/.art/"$artist"/"$album"/art.jpg && cover_img="$artist/$album/art.jpg" || cover_img="art.jpg"
    inputbar_opt="background-image: url(\"/home/user/Musica/.art/$cover_img\", width);padding:$cover;margin:4px 4px 10px;"

    # Options
    active='-a 2'
    urgent=''

    if [[ $status =~ "playing" ]]; then
        play=''
    else
        play=''
    fi

    if [[ $status =~ "random: on" ]]; then
        random=""
        [ -n "$active" ] && active+=",0" || active="-a 0"
    elif [[ $status =~ "repeat: on" ]]; then
        random=""
    fi

    list=''
    prev=''
    next=''

    # Rofi variables
    options="$random\n$prev\n$play\n$next\n$list"
    message=$(mpc --format "<b>%artist% - %title%</b>\n%album%" current)
}

handle_option() {
    if [ $1 == 'list' ]; then
        cover='55px'
        inputbar_opt="background-image: url(\"/home/user/Musica/.art/`mpc --format \"%albumartist%/%album%\" current`/art.jpg\", width);padding:$cover;margin:4px 4px 10px;"
        element_list="$(mpc --format '%title%' playlist)"
        current="$(mpc --format '%title%' current)"

        menu_list
        case $chosen in
            $back)
                cover='125px'
                main_menu;;
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
                done < <(echo -e "$element_list")
        esac
        current="$(mpc --format '%title%' current)"
        handle_option 'list'
    elif [ $1 == 'random' ]; then
        if [[ $status =~ "random: on" ]]; then
            mpc random off
        elif [[ $status =~ "repeat: on" ]]; then
            mpc random on
        fi
    fi
    main_menu
}

check_case() {
    case $chosen in
        $play)
            mpc toggle;;
        $prev)
            mpc prev;;
        $next)
            mpc next;;
        $list)
            handle_option 'list';;
        $random)
            handle_option 'random';;
        $cancel)
            exit;;
        *)
            exit;;
    esac
    main_menu
}

# Resources
window_opt="location: north; width:320px;"
extra_opt="-selected-row 2"

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
