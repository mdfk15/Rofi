#!/usr/bin/env bash

timer=7

# Options
select="麗"
window="" #
screen=""
delay="" #
cancel=""

# Variable passed to rofi
options="$select\n$window\n$screen\n$delay\n$cancel"

rofi_command="rofi -theme ../rasi/iconmenu.rasi"

setFilename() {
  directory="/path/to/dir/"
  filename="IMG_$(date +%Y%m%d_%H%M%S).jpg"
  filepath=$directory$filename
}

notify() {
  chosen=$(dunstify "$(echo -e 'Screenshot saved and copied to clipboard\nClick here to open')" -i accessories-screenshot --action="replyAction,reply")
  if [ $chosen == 2 ]
  then
    ristretto $filepath
  fi
}

n=0
for i in $(echo -e "$options"); do
  echo $i
  echo $n
  [[ "$i" == "$cancel" ]] && urgent="-u $n"
  [[ "$i" == "$select" ]] && selected_row="-selected-row $n"
  ((n+=1))
done

chosen="$(echo -e "$options" | $rofi_command -p "Screenshot" -mesg "/path/to/dir" $urgent -theme-str 'textbox-prompt-colon {str: "";}' -dmenu)"
sleep 0.1
case $chosen in
  $select)
    setFilename
    maim -Buosd 0.25 \
      | tee $filepath | xclip -selection c -t image/png
    notify
    ;;
  $window)
    setFilename
    maim -Buod 0.25 -i $(xdotool getactivewindow) \
      | tee $filepath | xclip -selection c -t image/png
    notify
    ;;
  $screen)
    setFilename
    maim -Buod 0.25 \
      | tee $filepath | xclip -selection c -t image/png
    notify
    ;;
  $delay)
    setFilename
    maim -Buod $timer \
      | tee $filepath | xclip -selection c -t image/png
    notify
    ;;
esac
