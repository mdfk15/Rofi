#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Screenshot #######

# Status
options() {

	# Options
	select="" #
	window=""
	screen=""
	delay=""
	cancel=""
	
	# Variable passed to rofi
	options="$select\n$window\n$screen\n$delay\n$cancel"
	message="~/Imagenes/Capturas-pantalla/"

	n=0
	for i in $(echo -e "$options"); do
	  [[ "$i" == "$cancel" ]] && urgent="-u $n"
	  [[ "$i" == "$select" ]] && selected_row="-selected-row $n"
	  ((n+=1))
	done
}

setFilename() {
  directory="/home/user/Imagenes/Capturas-pantalla/"
  filename="IMG_$(date +%Y%m%d_%H%M%S).jpg"
  filepath=$directory$filename
  [ -n "$delay_cmd" ] && sleep $timer || continue
}

notify() {
  chosen=$(dunstify "$(echo -e 'Screenshot saved and copied to clipboard\nClick here to open')" -i accessories-screenshot --action="replyAction,reply")
  if [ $chosen == 2 ]
  then
    ristretto $filepath
  fi
}

check_case() {
	case $chosen in
	  $select)
	    setFilename
	    maim -Buosd 0.25 \
	      | tee $filepath | xclip -selection c -t image/png
	    notify;;
	  $window)
	    setFilename
	    maim -Buod 0.25 -i $(xdotool getactivewindow) \
	      | tee $filepath | xclip -selection c -t image/png
	    notify;;
	  $screen)
	    setFilename
	    maim -Buod 0.25 \
	      | tee $filepath | xclip -selection c -t image/png
	    notify;;
	  $delay)
	    setFilename
	    maim -Buod $timer \
	      | tee $filepath | xclip -selection c -t image/png
	    notify;;
	esac
}

# Resources
title='Screenshot'
icon=''

# Timer
timer=7

path=$(dirname "$0")
source $path/base.sh

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
