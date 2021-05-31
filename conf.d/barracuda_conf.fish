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
#   -> Language definitions
#   -> Color definitions
#   -> Aliases
#   -> General configurations
#   -> Key bindings
#   -> Install Powerline fonts
#
###############################################################################

###############################################################################
# => Languages (SP-EN-FR)
###############################################################################

# Languages
set -U lang_sp 'Analizando y recopilando datos...' 'Comprimiendo...' 'No hay archivos de respaldo' 'Borrar' 'Todo' 'Borrar archivo' 'Borrar TODO (s/n)?' 'No se encontró ALMACENAMIENTO_EXTERNO.' 'El respaldo se guardará en ~/.backup_termux' 'Intente escribiendo' '¡Listo! Respaldo realizado con éxito' 'Uso: termux-backup [OPCION]...' '     termux-backup -c [ARCHIVO]...' 'Descripción:' 'Realiza un respaldo de los archivos de usuario y sistema' 'OPCION:' '-c --create		Crear nuevo respaldo' '-d --delete		Borrar archivo de respaldo' '-l --list		Listar archivos de respaldo' '-h --help		Muestra esta ayuda' 'ARCHIVO:' '<nombre_de_archivo>	Nombre del archivo de respaldo' '       Nombre de archivo     Tamaño    Fecha' 'Archivos de respaldo' 'Si no se especifica ninguna OPCION, se creará un archivo de respaldo con <Backup> como identificador por defecto' 'Cancelar' 'Copia de respaldo eliminada' 'Se eliminaron todos los arvivos de respaldos' 'Versión' 'Abortando...'
set -U lang_en 'Analizing and collecting data...' 'Compressing...' 'No backups found' 'Delete' 'All' 'Delete item' ' Delete ALL backups (y/n)? ' 'No EXTERNAL_STORAGE mounted.' 'Backup will be stored in ~/.backup_termux' 'Try using ' 'All done\! Backup has been successfuly finished' 'Usage: termux-backup [OPTION]...' '       termux-backup -c [FILE]...' 'Description:' 'Performs a backup of system and user\'s files' 'OPTION:' '-c --create		Create new backup' '-d --delete		Delete existing backup' '-l --list		List backup files' '-h --help		Show this help' 'FILE:' '<bakup_file_name>	Name of backup file' '           File name          Size      Date' 'Backup files' 'If no OPTION is defined, it will be created a backup with default identifier <Backup>' 'Cancel' 'popsBackup deleted' 'All backups has been deleted' 'Version' 'Aborting...'
set -U lang_fr 'Analyser et collecter des données...' 'Compresser...' 'Aucune sauvegarde trouvée' 'Supprimer' 'Tout' 'Supprimer l\'élément' 'Supprimer TOUT (o/n)?' 'Aucun STOCKAGE_EXTERNE monté.' 'La sauvegarde sera stockée dans ~/.backup_termux' 'Essayez d\'utiliser' 'Terminé! La sauvegarde est terminée avec succès' 'Utilisation: termux-backup [OPTION]...' '             termux-backup -c [FILE]...' 'Description:' 'Effectue une sauvegarde du système et des fichiers de l\'utilisateur' 'OPTION:' '-c --create		Créer une nouvelle sauvegarde' '-d --delete		Supprimer la sauvegarde existante' '-l --list		Liste les fichiers de sauvegarde' '-h --help		Afficher cette aide' 'FILE:' '<nom_du_fichier>	Nom du fichier de sauvegarde' '         Nom du fichier      Taille     Date' 'Fichiers de sauvegarde' 'Si aucune OPTION n\'est définie, il sera créé une sauvegarde avec l\'identifiant par défaut <Backup>' 'Annuler' 'Sauvegarde supprimée' 'Toutes les sauvegardes ont été supprimées' 'Version' 'Abandon...'

set -U g_lang_sp ' Documentación y Ayuda ' ' ⋙ Wiki:                   ' ' ⋙ Forum de la Comunidad:  ' ' ⋙ Chat en Gitter:         ' ' ⋙ Canal IRC:              ' ' Trabajo con paquetes ' ' ⋙ Buscar paquetes:        ' ' ⋙ Instalar un paquete:    ' ' ⋙ Actualizar un paquete:  ' ' Repositorios adicionales ' ' ⋙ Root:                   ' ' ⋙ Unstable:               ' ' ⋙ X11:                    ' 'Reporte cualquier problema en https://termux.com/issues ' 'Use la opción \'-h\' or \'--help\' para más información'
set -U g_lang_en ' Documents and help ' ' ⋙ Wiki:                   ' ' ⋙ Comunity Forum:         ' ' ⋙ Chat on Gitter:         ' ' ⋙ IRC Channel:            ' ' Working with packages ' ' ⋙ Search packages:        ' ' ⋙ Install packages:       ' ' ⋙ Update a package:       ' ' Extra repositories ' ' ⋙ Root:                   ' ' ⋙ Unstable:               ' ' ⋙ X11:                    ' 'Report any issue in https://termux.com/issues ' 'Try option \'-h\' or \'--help\' for more information'
set -U g_lang_fr ' Documents et aide ' ' ⋙ Wiki:		      ' ' ⋙ Forum communautaire:	      ' ' ⋙ Chat sur Gitter:	      ' ' ⋙ Canal IRC:		      ' ' Travailler avec les packages ' ' ⋙ Rechercher les packages:   ' ' ⋙ Installer les packages:    ' ' ⋙ Mettre à jour un package:  ' ' Référentiels supplémentaires ' ' ⋙ Root:		      ' ' ⋙ Unstable:		      ' ' ⋙ X11:			      ' 'Signaler tout problème dans https://termux.com/issues ' 'Utilisez l\'option \'-h\' ou \'--help\' pour plus d\'informations'

if not set -q b_lang
  set -U b_lang $lang_sp
  set -U bg_lang $g_lang_sp
end

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
# => Aliases
###############################################################################

alias ps "ps -ef"
alias ls "ls -gh"
alias version 'echo Barracuda v$barracuda_version'
alias backup "termux-backup"
alias spanish "language sp"
alias english "language en"
alias french "language fr"

###############################################################################
# => General configurations
###############################################################################

set -U barracuda_version "1.6.1"
set -U barracuda_tmpfile '/tmp/'(echo %self)'_barracuda_edit.fish'
set -U termux_path '/data/data/com.termux/files'
set -U theme_path (cd (status dirname); cd ..; pwd)

echo '' > $termux_path/usr/etc/motd
title " }><(({º> "- (date)

###############################################################################
# => Key bindings
###############################################################################

set fish_key_bindings fish_vi_key_bindings
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

if ! test -e $termux_path/home/.termux/font.ttf
  cp -f $theme_path/fonts/font.ttf $termux_path/home/.termux/
  termux-reload-settings
  commandline -f repaint
end
