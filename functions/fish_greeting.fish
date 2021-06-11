#############################################################
#
# Prompt theme name:
#   barracuda
#
# Description:
#   A fancy theme for the fish shell.
#
# Author:
#   Marvin Eversley Silva <meverss@outlook.com>
#
# Sections:
#   -> Welcome message
#
#############################################################

function fish_greeting -V barracuda_colors -d "Welcome message"
  if test -e $PATH/termux-toast
    termux-toast -s -b "#222222" -g top -c "#$barracuda_colors[5]" '}><(({º>'
  end
  echo (set_color -b black)(set_color $barracuda_colors[5])''(set_color -b $barracuda_colors[5])(set_color -o 000) "Barracuda v$barracuda_version" (set_color normal)(set_color $barracuda_colors[5])''(set_color normal)
  echo
  echo -e $bg_lang
end
