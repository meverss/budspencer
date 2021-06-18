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

  if test $git_show_info = 'on'; set git_switch $barracuda_icons[27]
  else; set git_switch $barracuda_icons[28]; end
  
  if not set -q barracuda_nobell; set bell_switch $barracuda_icons[27]
  else; set git_switch $barracuda_icons[28]; end

  if test $bat_icon = 'on'; set bat_switch $barracuda_icons[27]
  else; set git_switch $barracuda_icons[28]; end

  if test -z $barracuda_sessions_active; set session $b_lang[54]
  else; set session $barracuda_sessions_active; end

  echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[49] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)
  echo -e $h\n\t$b_lang[50]
  echo -e $i\t$barracuda_icons[44]$n$d $b_lang[51]$v 'Barracuda'
  echo -e $i\t$barracuda_icons[45]$n$d $b_lang[52]$v "v$barracuda_version"
  echo -e $i\t$barracuda_icons[13]$n$d $b_lang[53]$v "$session"
  echo -e $h\n\t$b_lang[55]
  echo -e $i\t$barracuda_icons[37]$n$d $b_lang[56]$v "$lang" | sed 's/es/Español/g' | sed 's/en/English/g'
  
end
