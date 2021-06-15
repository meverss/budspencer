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
#   -> General configurations
#   -> Colors definition
#   -> Language definition
#   -> Aliases
#   -> Key bindings
#   -> Install Powerline fonts
#
###############################################################################


###############################################################################
# => General configurations
###############################################################################
set -U barracuda_version "1.7.2"
set -U barracuda_tmpfile '/tmp/'(echo %self)'_barracuda_edit.fish'
set -U termux_path '/data/data/com.termux/files'
set tpath (string split '/' (status dirname))[1..-2]
set -U theme_path (string join '/' $tpath)
set info (command uname -s)

echo '' > $termux_path/usr/etc/motd

if test $info = 'Linux'; and contains 'Android' (string split " " (command uname -a))
  set info 'Android'
end

# OS Info
switch $info
  case 'Android'
    set -U b_os $info
    set -U i_os $barracuda_icons[25]
  case 'Darwin'
    set -U b_os 'Mac OS'
    set -U i_os $barracuda_icons[23]
  case 'Windows'
    set -U b_os $info
    set -U i_os $barracuda_icons[24]
  case '*'
    set -U b_os $info
    set -U i_os $barracuda_icons[26]
end

# Battery info
if not set -q ac_info_file
for ac in ac AC
  if test -d /sys/class/power_supply/$ac
    set b_path (string split '/' (readlink -f /sys/class/power_supply/$ac))[1..-2]
    set b_path (string join '/' $b_path)
    set -U ac_info_file (string split ":" (find $b_path -type f |xargs grep "POWER_SUPPLY_NAME=$ac" 2>/dev/null))[1]
    set -U battery_info_file (string split ":" (find $b_path -type f |xargs grep "POWER_SUPPLY_CAPACITY=" 2>/dev/null))[1]
    break
  end
end
end

# Window title
function wt -d 'Set window title'
  set -g window_title $argv
  function fish_title
    echo -n $window_title
  end
end

wt ' }><(({º> -' (date); tabs -2
###############################################################################
# => Reload settings
###############################################################################
function barracuda_reload -a opt -d 'Reload configuration'
  [ $opt ]; or set opt ""
  set current_path (pwd)
  switch $opt
    case "" "set barracuda_colors"
      source "$theme_path/conf.d/barracuda_conf.fish"
      source "$theme_path/functions/fish_prompt.fish"
      cd $current_path
    case "config"
      source "$theme_path/conf.d/barracuda_conf.fish"
      cd $current_path
    case "*"
      echo "$_: $b_lang[36] $argv"
  end
end

###############################################################################
# => Colors and icons definitions
###############################################################################
#------------------------------------------------------------------------------
# Define colors
#------------------------------------------------------------------------------
set -U barracuda_colors_dark 000 6a7a6a 445659 bbb b58900 222222 dc121f 9c9 777 268bd2 2aa198 666
set -U barracuda_colors_light 000 a9ba9d 9dc183 eee eedc82 333333 dc121f 9c9  aaa 2aa198 666

# Set "dark" the default color scheme
if not set -q barracuda_colors
  set -U barracuda_colors $barracuda_colors_dark
end
#__color_scheme
#------------------------------------------------------------------------------
# Define icons
#------------------------------------------------------------------------------
set -U barracuda_icons_dark                                            
set -U barracuda_icons_light                                            
#  
# Set "dark" the default icons scheme
if not set -q barracuda_icons
  set -U barracuda_icons $barracuda_icons_dark
  set -U i_mode $barracuda_icons[1]
end

#------------------------------------------------------------------------------
# Cursor color changes according to vi-mode
# Define values for: normal_mode insert_mode visual_mode
#------------------------------------------------------------------------------
set -U barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"

###############################################################################
# => Languages (SP-EN)
###############################################################################
set -l bl (set_color -o $barracuda_colors[5])'}><(({º>'(set_color -b normal $barracuda_colors[9])
set -l fs (set_color $barracuda_colors[4])'fish'(set_color -b normal $barracuda_colors[9])
set -l bh (set_color $barracuda_colors[4])'barracuda_help'(set_color -b 000 $barracuda_colors[9])
set -U lang_sp 'Recopilando datos...' 'Comprimiendo...' 'No hay archivos de respaldo' 'Borrar' 'Todo' 'Borrar archivo' 'Borrar TODO (s/n)?' 'No se encontró ALMACENAMIENTO_EXTERNO.' 'El respaldo se guardará en ~/.backup_termux' 'Intente escribiendo' '¡Listo! Respaldo realizado con éxito' 'Uso: backup [OPCION]...' '     backup -c [ARCHIVO]...' 'Descripción:' 'Realiza un respaldo de los archivos de usuario y sistema' 'OPCION:' '-c --create		Crear nuevo respaldo' '-d --delete		Borrar archivo de respaldo' '-l --list		Listar archivos de respaldo' '-h --help		Muestra esta ayuda' 'ARCHIVO:' '<nombre_de_archivo>	  Nombre del archivo de respaldo' '         Nombre de archivo     Tamaño       Fecha' 'Archivos de respaldo' 'Si no se especifica ninguna OPCION, se creará un archivo de respaldo con <Backup> como identificador por defecto' 'Cancelar' 'Copia de respaldo eliminada' 'Se eliminaron todos los arvivos de respaldos' 'Versión' 'Abortando...'\
               'Cambiar fuente' 'Aplicar' 'Fuente cambiada a' 'Ir' 'Borrar' 'opción inválida' 'El historial de directorios está vacío. Se creará de manera automática.' 'Historial de directorios' '\t  Directorio' 'La lista de marcadores esta vacía.' 'Lista de marcadores' '\t    Marcadores' 'Historial de comandos' '\t    Comandos' 'El historial de comandos esta vacío. Se creará de manera automática.' 'Sesiones' '\t    Nombre de sesión' 'No hay ninguna sesión guardada'
set -U lang_en 'Collecting data...' 'Compressing...' 'No backups found' 'Delete' 'All' 'Delete item' ' Delete ALL backups (y/n)? ' 'No EXTERNAL_STORAGE mounted.' 'Backup will be stored in ~/.backup_termux' 'Try using ' 'All done! Backup has been successfuly finished' 'Usage: backup [OPTION]...' '       backup -c [FILE]...' 'Description:' 'Performs a backup of system and user\'s files' 'OPTION:' '-c --create		Create new backup' '-d --delete		Delete existing backup' '-l --list		List backup files' '-h --help		Show this help' 'FILE:' '<bakup_file_name>	Name of backup file' '              File name         Size        Date' 'Backup files' 'If no OPTION is defined, it will be created a backup with default identifier <Backup>' 'Cancel' 'Backup deleted' 'All backups has been deleted' 'Version' 'Aborting...'\
               'Change font' 'Apply' 'Font changed to' 'Goto' 'Erase' 'invalid option' 'Directory history is empty. It will be created automatically.' 'Directory history' '\t  Directory' 'Bookmark list is empty.' 'Bookmarks list' '\t    Bookmarks' 'Command history' '\t    Commands' 'Command history is empty. It will be created automatically.' 'Sessions' '\t    Session name' 'No session saved.'

set -U g_lang_sp "$bl Un tema elegante para el shell $fs.\nEscriba $bh para una documentación detallada."
set -U g_lang_en "$bl A fancy theme for the $fs shell.\nType $bh for a complete documentation."

function ch_lang -a lang -V b_lang -V bg_lang -d 'Change language'
  [ $lang ]; or set lang ""
  switch $lang
    case 'sp'
      set -U b_lang $lang_sp
      set -U bg_lang $g_lang_sp
      set -U man_lang 'barracuda_sp'
      if test (tput cols) -le 56; set -U lang 'es'
      else; set -U lang 'español'; end
      set -U yes_no s n t c b
      barracuda_reload
      return

    case 'en'
      set -U b_lang $lang_en
      set -U bg_lang $g_lang_en
      set -U man_lang 'barracuda_en'
      if test (tput cols) -le 56; set -U lang 'en'
      else; set -U lang 'english'; end
      set -U yes_no y n a c d
      barracuda_reload
      return
  end
end

if not set -q b_lang
  ch_lang sp
end

###############################################################################
# => Aliases
###############################################################################
function ps -w ps
 command ps -ef | awk '{print $2"\t"$8}'
end
alias ls "ls -gh"
alias version 'echo Barracuda v$barracuda_version'
alias barracuda_help 'man $man_lang'
alias spanish "ch_lang sp"
alias español "ch_lang sp"
alias english "ch_lang en"
alias ingles "ch_lang en"

###############################################################################
# => Key bindings
###############################################################################

set -U fish_key_bindings fish_vi_key_bindings
bind '#' __barracuda_toggle_symbols
bind -M visual '#' __barracuda_toggle_symbols
bind ' ' __barracuda_toggle_pwd
bind -M visual ' ' __barracuda_toggle_pwd
bind L __barracuda_cd_next
bind H __barracuda_cd_prev
bind m mark
bind M unmark
bind . __barracuda_edit_commandline
bind -M insert \r __barracuda_preexec
bind \r __barracuda_preexec

###############################################################################
# => Install Powerline fonts (Termux)
###############################################################################
if test -f $PREFIX/bin/termux-info
  set -g fonts 'Monofur' 'DejaVu' 'FiraCode' 'Go'
  set -g DejaVu 'dejavu.ttf'
  set -g FiraCode 'firacode.ttf'
  set -g Go 'go.ttf'
  set -g Monofur 'monofur.ttf'

  if not set -q font
    set -U font $Monofur
  end

  switch $b_os
    case 'Android'
      if ! test -e $termux_path/home/.termux/font.ttf
        or ! cmp -s $theme_path/fonts/$font $HOME/.termux/font.ttf 2>/dev/null
        cp -f $theme_path/fonts/$font $HOME/.termux/font.ttf 2>/dev/null
        termux-reload-settings
        commandline -f repaint
      end
    case 'Darwin'
      set font_dir "$HOME/Library/Fonts"
      mkdir -p $font_dir
      cp -f $theme_path/fonts/$font $font_dir/$font 2>/dev/null
      fc-cache -f "$font_dir"
      barracuda_reload
    case '*'
      set font_dir "$HOME/.local/share/fonts"
      mkdir -p $font_dir
      cp -f $theme_path/fonts/$font $font_dir/$font 2>/dev/null      
      fc-cache -f "$font_dir"
      barracuda_reload
  end
end
