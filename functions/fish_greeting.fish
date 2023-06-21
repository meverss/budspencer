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
if [ $USER != 'root' ]
function fish_greeting -d "Welcome message"
  set -l bl (set_color -o $barracuda_colors[5])'}⋟<(({>'(set_color -b normal $barracuda_colors[9])
  set -l fs (set_color $barracuda_colors[4])'fish'(set_color -b normal $barracuda_colors[9])
  set -l bh (set_color $barracuda_colors[4])'barracuda_help'(set_color -b 000 $barracuda_colors[9])
  set -U g_lang_sp "Un tema elegante para el shell $fs.\nEscriba $bh para una documentación detallada."
  set -U g_lang_en "A fancy theme for the $fs shell.\nType $bh for a complete documentation."
  if [ -e $PREFIX/bin/termux-info ]
    echo '' > $termux_path/usr/etc/motd 2>/dev/null
  else
    echo '' > /etc/motd 2>/dev/null
  end
  
  switch $lang
    case 'es' 'español'
      set -U bg_lang $g_lang_sp
    case 'en' 'english'
      set -U bg_lang $g_lang_en
  end

  if test -e $PATH/termux-toast 2>/dev/null
    termux-toast -s -b "#222222" -g top -c "#$barracuda_colors[5]" '}⋟<(({º>'
  end

  echo (set_color -b black)(set_color $barracuda_colors[5])''(set_color -b $barracuda_colors[5])(set_color -o 000) "Barracuda v$barracuda_version" (set_color normal)(set_color $barracuda_colors[5])''(set_color normal)
  echo
  echo -e $bl $bg_lang
end
end

check_apps

