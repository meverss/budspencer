###############################################################################
#
# Prompt theme name:
#   barracuda
#
# Description:
#   a sophisticated airline/powerline theme
#
# Author:
#   Marvin Eversley Silva <meverss@gmail.com>
#
# Sections:
#   -> Color definitions
#   -> Language definitions
#   -> Aliases
#   -> General configurations
#   -> Key bindings
#   -> Install Powerline fonts
#
###############################################################################

###############################################################################
# => Color definitions
###############################################################################
#------------------------------------------------------------------------------
# Define colors
#------------------------------------------------------------------------------
set -U barracuda_night 000000 083743 445659 fdf6e3 b58900 cb4b16 dc121f af005f 6c71c4 268bd2 2aa198 859900
set -U barracuda_day 000000 333333 666666 ffffff ffff00 ff6600 ff0000 ff0033 3300ff 00aaff 00ffff 00ff00

if not set -q barracuda_colors
  set -U barracuda_colors $barracuda_night
end

#------------------------------------------------------------------------------
# Cursor color changes according to vi-mode
# Define values for: normal_mode insert_mode visual_mode
#------------------------------------------------------------------------------
set -U barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"

###############################################################################
# => Languages (SP-EN)
###############################################################################
set -l bl (set_color fb0)'}><(({º>'(set_color -b normal 555)
set -l bh (set_color $barracuda_colors[6])'barracuda_help'(set_color -b 000 555)
set -U lang_sp 'Analizando y recopilando datos...' 'Comprimiendo...' 'No hay archivos de respaldo' 'Borrar' 'Todo' 'Borrar archivo' 'Borrar TODO (s/n)?' 'No se encontró ALMACENAMIENTO_EXTERNO.' 'El respaldo se guardará en ~/.backup_termux' 'Intente escribiendo' '¡Listo! Respaldo realizado con éxito' 'Uso: termux-backup [OPCION]...' '     termux-backup -c [ARCHIVO]...' 'Descripción:' 'Realiza un respaldo de los archivos de usuario y sistema' 'OPCION:' '-c --create		Crear nuevo respaldo' '-d --delete		Borrar archivo de respaldo' '-l --list		Listar archivos de respaldo' '-h --help		Muestra esta ayuda' 'ARCHIVO:' '<nombre_de_archivo>	Nombre del archivo de respaldo' '       Nombre de archivo     Tamaño    Fecha' 'Archivos de respaldo' 'Si no se especifica ninguna OPCION, se creará un archivo de respaldo con <Backup> como identificador por defecto' 'Cancelar' 'Copia de respaldo eliminada' 'Se eliminaron todos los arvivos de respaldos' 'Versión' 'Abortando...'
set -U lang_en 'Analizing and collecting data...' 'Compressing...' 'No backups found' 'Delete' 'All' 'Delete item' ' Delete ALL backups (y/n)? ' 'No EXTERNAL_STORAGE mounted.' 'Backup will be stored in ~/.backup_termux' 'Try using ' 'All done\! Backup has been successfuly finished' 'Usage: termux-backup [OPTION]...' '       termux-backup -c [FILE]...' 'Description:' 'Performs a backup of system and user\'s files' 'OPTION:' '-c --create		Create new backup' '-d --delete		Delete existing backup' '-l --list		List backup files' '-h --help		Show this help' 'FILE:' '<bakup_file_name>	Name of backup file' '           File name          Size      Date' 'Backup files' 'If no OPTION is defined, it will be created a backup with default identifier <Backup>' 'Cancel' 'popsBackup deleted' 'All backups has been deleted' 'Version' 'Aborting...'

set -U g_lang_sp "$bl Un tema elegante y poderoso para el shell fish.\nEscriba $bh para una documentación completa."
set -U g_lang_en "$bl A fancy and powerful theme for the fish shell.\nType $bh for a complete documentation."

function __ch_lang -a lang -d 'Change language'
switch $lang
  case 'sp'
  clear
    set -U b_lang $lang_sp
    set -U bg_lang $g_lang_sp
    set -U man_lang 'barracuda_sp'
    set -U lang 'español'
    set -U yes_no s n t c
    termux-reload-settings
    fish_greeting
    commandline -f repaint
    return

  case 'en'
  clear
    set -U b_lang $lang_en
    set -U bg_lang $g_lang_en
    set -U man_lang 'barracuda_en'
    set -U lang 'english'
    set -U yes_no y n a c
    termux-reload-settings
    fish_greeting
    commandline -f repaint
    return
end
end

if not set -q b_lang
  __ch_lang sp
end



###############################################################################
# => Aliases
###############################################################################
alias ps "ps -ef"
alias ls "ls -gh"
alias version 'echo Barracuda v$barracuda_version'
alias barracuda_help 'man $man_lang'
alias backup "termux-backup"
alias spanish "__ch_lang sp"
alias english "__ch_lang en"

###############################################################################
# => General configurations
###############################################################################
set -U barracuda_version "1.7.0"
set -U b_os (uname -o)
set -U barracuda_tmpfile '/tmp/'(echo %self)'_barracuda_edit.fish'
set -U termux_path '/data/data/com.termux/files'
set -U theme_path (cd (status dirname); cd ..; pwd)

echo '' > $termux_path/usr/etc/motd

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
# => Install Powerline fonts
###############################################################################
set -g fonts 'Default' 'DejaVu' 'FiraCode' 'Go' 'Hermit' 'Monofur'
set -g DejaVu 'dejavu.ttf'
set -g FiraCode 'firacode.ttf'
set -g Hermit 'hermit.ttf'
set -g Monofur 'monofur.ttf'
set -g Default $Monofur

if not set -q font
  set -U font $Default
end

switch $b_os
  case 'Android'
    if ! test -e $termux_path/home/.termux/font.ttf
    or ! cmp -s $theme_path/fonts/$font $termux_path/home/.termux/font.ttf 2> /dev/null
      cp -f $__theme_path/fonts/$font $termux_path/home/.termux/font.ttf 2> /dev/null
      termux-reload-settings
      commandline -f repaint
    end
end
