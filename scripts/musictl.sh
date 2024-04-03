#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Musictl #######

## CREATE CHECK FUNCTIONS!

# Functions
options() {
    dunstctl close
    title='Music'
    icon=''
    selected_row='2'
    status=$(mpc)
    title="$(mpc status '%songpos%/%length%')"
    cover='170px' # Cover art images size
    song_title=$(mpc --format '%title%' current)

    # Check if file exist, if not it set a default cover image
    previewname="$HOME/.config/ncmpcpp/previews/$(mpc --format %album% current | base64).png"
    [ -e "$previewname" ] || previewname=$HOME/.config/ncmpcpp/previews/art.png
    cover_opt="background-image: url(\"$previewname\", width);"
    message_opt="background-color:transparent;"
    inputbar_opt=''

    # Options
    active=''
    urgent='-u 2'

    # ICONS:              
    if [[ $status =~ "playing" ]]; then
        play=''
    else
        play=''
    fi

    if [[ $status =~ "random: on" ]]; then
        random=""
        #[ -n "$active" ] && active+=",0" || active="-a 0"
    elif [[ $status =~ "repeat: on" ]]; then
        random=""
    fi

    list=''
    prev=''
    next=''
    player=''

    # Rofi variables
    if [ -n "$song_title" ]; then
	    message=$(mpc --format "<b><span foreground='white'>%title%</span></b>\n%artist%\n%album%" current)
	    options="$random\n$prev\n$play\n$next\n$list"
    else
	    if [ "$title" == '0/0' ];then
		    message="List empty"
		    options="$random\n$player"
	    else
		    message='Select song to play'
		    handle_option 'list'

		    message=$(mpc --format "<b><span foreground='white'>%title%</span></b>\n%artist%\n%album%" current)
	    	    options="$random\n$prev\n$play\n$next\n$list"
	    fi
    fi
}

handle_option() {
    if [ $1 == 'list' ]; then
	title='Playlist'
        cover='55px'
	icon=''
	selected_row=1
	previewname="$HOME/.config/ncmpcpp/previews/$(mpc --format %album% current | base64).png"
	[ -e "$previewname" ] || previewname=$HOME/.config/ncmpcpp/previews/art.png

        cover_opt="background-image: url(\"$previewname\", width);"
        message_opt="background-color : var(background);"
        inputbar_opt="background-color : var(background);"

	#element_list="$(mpc --format '%title%' playlist)"
	element_list="$(mpc --format '%title%:%artist%' playlist)"
        current="$(mpc --format '%title%:%artist%' current)"

        menu_list
    elif [ $1 == 'random' ]; then
        if [[ $status =~ "random: on" ]]; then
            mpc random off > /dev/null 2>&1
        elif [[ $status =~ "repeat: on" ]]; then
            mpc random on > /dev/null 2>&1
        fi
    fi
}

element_option() {
	song="$1"
        n=1
        while read line; do
            if [[ "$song" == "${line%:*}" && -n "$song" ]]; then
                mpc play $n > /dev/null 2>&1
		break
            elif [ -z "$song" ]; then
                exit
            fi
            ((n+=1))
        done < <(echo -e "$element_list")
	songinfo
        current="$(mpc --format '%title%' current)"
	message=$(mpc --format "<b><span foreground='white'>%title%</span></b>\n%artist%\n%album%" current)
        handle_option 'list'
}

check_case() {
    case $chosen in
        $play)
            mpc toggle > /dev/null 2>&1;;
        $prev)
            mpc prev > /dev/null 2>&1;;
        $next)
            mpc next > /dev/null 2>&1;;
        $list)
            handle_option 'list';;
        $random)
            handle_option 'random';;
    	$player)
	    alacritty -e ncmpcpp -s browser;;
        $cancel)
            exit;;
        *)
            exit;;
    esac
    main_menu
}

# Resources
path=$(dirname "$0")
source $path/base.sh

icon_type='song'
icon_current='song-current'

window_opt="location: north; width:380px;"
icon_menu='music.rasi'
list_menu='listmenu-entry.rasi'

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
