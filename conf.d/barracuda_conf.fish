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
#   -> General config
#   -> Reload settings
#   -> Colors and icons definition
#   -> Language definition
#   -> Aliases
#   -> Key bindings
#   -> Install Powerline fonts
#
###############################################################################

###############################################################################
# => General config
###############################################################################
set -U barracuda_version "1.7.3"
set -U barracuda_tmpfile '/tmp/'(echo %self)'_barracuda_edit.fish'
set -U termux_path '/data/data/com.termux/files'
set -U theme_path (status dirname | sed -r 's/barracuda.*/barracuda/')
set info (uname)

# OS Info
if contains 'Android' (string split ' ' (uname -a))
    set -U b_os 'Android'
    set -U i_os $barracuda_icons[23]
else
  switch $info
    case 'Darwin'
      set -U b_os 'Mac OS'
      set -U i_os $barracuda_icons[21]
    case 'Windows'
      set -U b_os $info
      set -U i_os $barracuda_icons[22]
    case '*'
      set -U b_os $info
      set -U i_os $barracuda_icons[24]
  end
end

#set distro 'Debian' 'Fedora' 'Arch' 'Ubuntu' 'Suse' 'Gentoo' 'BSD'\
#  for x in (seq (count $distro))
#    if contains $distro[$x] (string split ' ' (uname -a))
#      switch $distro[$x]
#        case 'Android'
#          echo Android
#        case 'aarch64'
#          echo CPU
#      end
#    end
#  end

# Battery info
if not set -q ac_info_file; or not set -q battery_info_file
  for ac in 'ac' 'AC'
    if test -d /sys/class/power_supply/$ac
      set b_path (readlink -f /sys/class/power_supply/$ac | sed "s/\/$ac//g")
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

wt ' }⋟<(({º> -' (date); tabs -2

###############################################################################
# => Reload settings
###############################################################################
function barracuda_reload -a opt -d 'Reload configuration'
  [ $opt ]; or set opt ""
  set current_path (pwd)
  set item (contains -i %self $barracuda_sessions_active_pid 2> /dev/null)
  switch $opt
    case ""
      __barracuda_detach_session $item
      source "$theme_path/conf.d/barracuda_conf.fish"
      source "$theme_path/functions/fish_prompt.fish"
      cd $current_path
      tput cuu 3
      tput ed
      set pcount 1
    case "config"
      source "$theme_path/conf.d/barracuda_conf.fish"
      cd $current_path
      tput cuu 3
      tput ed
      set pcount (expr $pcount - 1)
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
set -U barracuda_colors_dark 000 6a7a6a 445659 bbb b58900 222222 dc121f 9c9 777 268bd2 2aa198 666 333
set -U barracuda_colors_light 000 a9ba9d 9dc183 eee eedc82 333333 dc121f 9c9  aaa 268bd2 2aa198 666 444

#------------------------------------------------------------------------------
# Define icons
#------------------------------------------------------------------------------
set barracuda_icons_dark  \uf186 \ue725 \uf1f7 \uf0a2 \uf115 \ue5fe \uf11d \uf489 \uf006 \uf014 \uf2c0 \uf42e \uf467 \uf101 \uf24d \uf023 \uf031 \ue231 \uf1c6 \uf455 \uF179 \uf17a \uf17b \uf17c \uf25d \uf1Ab \ue62b \uf440 \u2191 \u2193 \uf12e \uf02c \uf1fc \ue27a
set barracuda_icons_light \uf0a3 \ue725 \uf1f6 \uf0f3 \uf07c \ue5fe \uf024 \ue795 \uf005 \uf1f8 \uf007 \uf42e \uf467 \uf101 \uf24d \uf023 \uf031 \ue231 \uf1c6 \uf455 \uF179 \uf17a \uf17b \uf17c \uf25d \uf1Ab \ue62b \uf440 \u2191 \u2193 \uf12e \uf02c \uf1fc \ue27a
set barracuda_icons_linux \uE77D \uE73A \uF30E \uF30D \uF268 \uF303 \uF30B \uF304 \uF305 \uF307 \uF309 \uF30C \uF311 \uF312
set barracuda_icons_plang \ue73c \ue718 \ue791
set battery_icons \uf582 \uf579 \uf57a \uf57b \uf57c \uf57d \uf57e \uf57f \uf580 \uf581 \uf578 \uf583 \ufba3

###############################################################################
# => Languages (SP-EN)
###############################################################################
set lang_sp 'Recopilando datos...' 'Comprimiendo...' 'No hay archivos de respaldo' 'Borrar' 'Todo' 'Borrar archivo' 'Borrar TODO (s/n)?' 'No se encontró ALMACENAMIENTO_EXTERNO.' 'El respaldo se guardará en ~/.backup_termux' 'Intente escribiendo' '¡Listo! Respaldo realizado con éxito' 'Uso: backup [OPCION]...' '     backup -c [ARCHIVO]...' 'Descripción:' 'Realiza un respaldo de los archivos de usuario y sistema' 'OPCION:' '-c --create		Crear nuevo respaldo' '-d --delete		Borrar archivo de respaldo' '-l --list		Listar archivos de respaldo' '-h --help		Muestra esta ayuda' 'ARCHIVO:' '<nombre_de_archivo>	  Nombre del archivo de respaldo' '         Nombre de archivo     Tamaño       Fecha' 'Archivos de respaldo' 'Si no se especifica ninguna OPCION, se creará un archivo de respaldo con <Backup> como identificador por defecto' 'Cancelar' 'Copia de respaldo eliminada' 'Se eliminaron todos los arvivos de respaldos' 'Versión' 'Abortando...'\
            'Cambiar fuente' 'Aplicar' 'Fuente cambiada a' 'Ir' 'Borrar' 'opción inválida' 'El historial de directorios está vacío. Se creará de manera automática.' 'Historial de directorios' '\t     Directorio' 'La lista de marcadores esta vacía.' 'Lista de marcadores' '\t    Marcadores' 'Historial de comandos' '\t    Comandos' 'El historial de comandos esta vacío. Se creará de manera automática.' 'Sesiones' '\t    Nombre de sesión' 'No hay ninguna sesión guardada'\
            'Información del tema' 'General' 'Nombre:' 'Versión:' 'Sesión activa:' '(ninguna)' 'Interfaz' 'Idioma:' 'Esquema de color:' 'Características' 'Mostrar stado de repositorio Git:' 'Notificaciones activas:' 'Mostrar estado de la batería:' 'Si' 'No'
set lang_en 'Collecting data...' 'Compressing...' 'No backups found' 'Delete' 'All' 'Delete item' ' Delete ALL backups (y/n)? ' 'No EXTERNAL_STORAGE mounted.' 'Backup will be stored in ~/.backup_termux' 'Try using ' 'All done! Backup has been successfuly finished' 'Usage: backup [OPTION]...' '       backup -c [FILE]...' 'Description:' 'Performs a backup of system and user\'s files' 'OPTION:' '-c --create		Create new backup' '-d --delete		Delete existing backup' '-l --list		List backup files' '-h --help		Show this help' 'FILE:' '<bakup_file_name>	Name of backup file' '              File name         Size        Date' 'Backup files' 'If no OPTION is defined, it will be created a backup with default identifier <Backup>' 'Cancel' 'Backup deleted' 'All backups has been deleted' 'Version' 'Aborting...'\
            'Change font' 'Apply' 'Font changed to' 'Goto' 'Erase' 'invalid option' 'Directory history is empty. It will be created automatically.' 'Directory history' '\t     Directory' 'Bookmark list is empty.' 'Bookmarks list' '\t    Bookmarks' 'Command history' '\t    Commands' 'Command history is empty. It will be created automatically.' 'Sessions' '\t    Session name' 'No session saved.'\
            'Theme info' 'General' 'Name: ' 'Version:' 'Active session:' '(none)' 'Interface' 'Language:' 'Color scheme:' 'Features' 'Show Git status:' 'Active notifications:' 'Show battery status icon:' 'Yes' 'No'

function ch_lang -a lang -d 'Change language'
  [ $lang ]; or set lang ""
  switch $lang
    case 'sp'
      set -U b_lang $lang_sp
      set -U bg_lang $g_lang_sp
      set -U man_lang 'barracuda_help_es.gz'
      set -U yes_no s n t c b
      set -U lang 'español'
      barracuda_reload config
      return

    case 'en'
      set -U b_lang $lang_en
      set -U bg_lang $g_lang_en
      set -U man_lang 'barracuda_help_en.gz'
      set -U yes_no y n a c d
      set -U lang 'english'
      barracuda_reload config
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
alias spanish "ch_lang sp"
alias english "ch_lang en"

###############################################################################
# => Key bindings
###############################################################################

set -U fish_key_bindings fish_vi_key_bindings
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
if [ -f $PREFIX/bin/termux-info ]
  set -g fonts 'Monofur' 'DejaVu' 'FiraCode' 'Go' 'Ubuntu'
  set -g DejaVu 'DejaVu Sans Mono'
  set -g FiraCode 'Fira Code Regular'
  set -g Go 'Go Mono'
  set -g Monofur 'Monofur'
  set -g Ubuntu 'Ubuntu'
  set -g DroidSans 'Droid Sans Mono Nerd Font Complete'

  if not set -q font
    set -U font $Monofur
  end

  switch $b_os
    case 'Android'
      if ! [ -e $HOME/.termux/font.ttf ]
        or ! cmp -s $theme_path/fonts/$font.ttf $HOME/.termux/font.ttf 2>/dev/null
        cp -f $theme_path/fonts/$font.ttf $HOME/.termux/font.ttf 2>/dev/null
        termux-reload-settings
        commandline -f repaint
      end
    case 'Darwin'
      set font_dir "$HOME/Library/Fonts"
      mkdir -p $font_dir
      cp -f $theme_path/fonts/$DroidSans.otf $font_dir/$DroidSans.otf 2>/dev/null
      fc-cache -f "$font_dir"
      barracuda_reload
    case '*'
      set font_dir "$HOME/.local/share/fonts"
      mkdir -p $font_dir
      cp -f $theme_path/fonts/$DroidSans.otf $font_dir/$DroidSans.otf 2>/dev/null      
      fc-cache -f "$font_dir"
      barracuda_reload
  end
end
