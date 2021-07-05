###############################################################################
#
# Prompt theme name:
#   barracuda
#
# Description:
#   A fancy theme for the fish shell.
#
# Author:
#   Marvin Eversley Silva <meverss@gmail.com>
#
# Sections:
#   -> Barracuda info
#
###############################################################################

###############################################################################
# => Barracuda info
###############################################################################
function barracuda_info -d 'Show theme info'
  set h (set_color $barracuda_colors[5])
  set d (set_color $barracuda_colors[9])
  set v (set_color $barracuda_colors[2])
  set i (set_color $barracuda_colors[3])
  set n (set_color normal)

  if test $git_show_info = 'on'; set git_active $b_lang[62]
  else; set git_active $b_lang[63]; end
  
  if not set -q barracuda_nobell; set bell_active $b_lang[62]
  else; set bell_active $b_lang[63]; end

  if test $bat_icon = 'on'; set bat_active $b_lang[62]
  else; set bat_active $b_lang[63]; end

  if test -z $barracuda_sessions_active; set session $b_lang[54]
  else; set session $barracuda_sessions_active; end

  echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[49] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)
  echo -e $h\n\t$b_lang[50]
  echo -e $i\t$barracuda_icons[31]$n$d $b_lang[51]$v 'Barracuda'
  echo -e $i\t$barracuda_icons[32]$n$d $b_lang[52]$v "v$barracuda_version"
  echo -e $i\t$barracuda_icons[11]$n$d $b_lang[53]$v "$session"
  echo -e $h\n\t$b_lang[55]
  echo -e $i\t$barracuda_icons[26]$n$d $b_lang[56]$v "$lang" | sed 's/es/Español/g; s/en/English/g'
  echo -e $i\t$barracuda_icons[33]$n$d $b_lang[57]$v (echo $scheme | sed 's/^[a-z]*/\u&/g')
  echo -e $h\n\t$b_lang[58]
  echo -e $i\t$barracuda_icons[2]$n$d $b_lang[59]$v "$git_active"  
  echo -e $i\t$barracuda_icons[4]$n$d $b_lang[60]$v "$bell_active"
  echo -e $i\t$battery_icons[11]$n$d $b_lang[61]$v "$bat_active"
end

