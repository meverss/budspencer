#############################################################
#
# Prompt theme name:
#   barracuda
#
# Description:
#   a sophisticated airline/powerline theme
#
# Author:
#   Marvin Eversley Silva <meverss@outlook.com>
#
# Sections:
#   -> Welcome message
#
#############################################################

function fish_greeting -d "Welcome message"
  if test -e $termux_path/usr/bin/termux-toast
    termux-toast -s -b "#222222" -g top -c "#b58900" '}><(({º>'
  end
  echo (set_color -b black)(set_color b58900)''(set_color -b b58900)(set_color -o 000) "Barracuda v$barracuda_version" (set_color normal)(set_color b58900)''
end
