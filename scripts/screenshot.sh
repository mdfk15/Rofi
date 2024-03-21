#!/usr/bin/env bash
#
## Author   : mdfk@Elite <2022>
## Github   : @mdfk15
#
####### Rofi Screenshot #######

# Setup
directory="/home/mdfk/registre/imagenes/capturas-pantalla/"

# Status
options() {

	# Options
	select="" #
	window=""
	screen=""
	delay=""
	cancel=""
	
	# Variable passed to rofi
	options="$select\n$window\n$screen\n$delay"
	message=" ${timer}s"

	n=0
	for i in $(echo -e "$options"); do
	  [[ "$i" == "$cancel" ]] && urgent="-u $n"
	  [[ "$i" == "$select" ]] && selected_row="-selected-row $n"
	  ((n+=1))
	done
}

setFilename() {
  filename="IMG_$(date +%Y%m%d_%H%M%S).jpg"
  filepath=$directory$filename
  [ -n "$delay_cmd" ] && sleep $timer || continue
}

notify() {
  chosen=$(dunstify -a "Screenshot" "$(echo -e 'Saved and copied to clipboard\nClick here to open')" -i $filepath --action="replyAction,reply")
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

path=$(dirname "$0")
source $path/base.sh


# Resources
title='Screenshot'
icon=''
icon_menu='iconvertical.rasi'

# Timer
timer=7

case $1 in
    --status)
        pass ;;
    *)
        main_menu;;
esac
