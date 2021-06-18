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
#   -> Functions
#     -> Ring bell
#     -> Battery indicator
#     -> Window title
#     -> Environment
#     -> Pre execute
#     -> Directory history
#     -> Command history
#     -> Bookmarks
#     -> Sessions
#     -> Git segment
#     -> Bind-mode segment
#     -> Symbols segment
#     -> Backup (Termux)
#     -> Colored Man Pages (Thanks to PatrickF1)
#     -> Update Git project
#   -> Prompt initialization
#   -> Left prompt
#   -> Right prompt
#
###############################################################################

###############################################################################
# => Functions
###############################################################################
#------------------------------------------------------------
# => Ring bell
#------------------------------------------------------------
if set -q barracuda_nobell
  function __barracuda_urgency -d 'Do nothing.'
    set -U i_bell $barracuda_icons[5]
  end
else
  function __barracuda_urgency -d 'Ring the bell in order to set the urgency hint flag.'
    set -U i_bell $barracuda_icons[6]
    echo -n \a
  end
end

function bell -a bell -d 'Enable/Disable bell'
  switch $bell
    case 'on'
      set -e barracuda_nobell
      barracuda_reload
    case 'off'
      set -U barracuda_nobell
      barracuda_reload
  end
end

#------------------------------------------------------------
# => Battery indicator
#------------------------------------------------------------
# Set default ON
if not set -q bat_icon; set -U bat_icon 'on'; end

function battery_level -d 'Shows battery level'
if test $bat_icon = 'on'
  set ac_online (string split "=" (cat $ac_info_file | grep 'ONLINE'))[2]

  if test $ac_online -gt 0
    set -g i_battery $battery_icons[6]
  else

    set -l blevel (string split "=" (cat $battery_info_file | grep 'CAPACITY'))[2]
    set -l bstatus (string split "=" (cat $battery_info_file | grep 'STATUS'))[2]

    if not test $bstatus = 'Charging'; and contains $blevel (seq 15)
      set -g i_battery (set_color $barracuda_colors[7])$battery_icons[5]
    else if not test $bstatus = 'Charging'; and contains $blevel (seq 16 44)
      set -g i_battery $battery_icons[4]
    else if not test $bstatus = 'Charging'; and contains $blevel (seq 46 64)
      set -g i_battery $battery_icons[3]
    else if not test $bstatus = 'Charging'; and contains $blevel (seq 66 89)
      set -g i_battery $battery_icons[2]
    else if not test $bstatus = 'Charging'; and contains $blevel (seq 91 100)
      set -g i_battery $battery_icons[1]
    else if test $bstatus = 'Charging'
      set -g i_battery $battery_icons[6]
    end
  end
end
end

function battery -a opt -d 'Enable/Disable battery icon'
  switch $opt
    case 'on'
     set -U bat_icon 'on'
      battery_level
      barracuda_reload
    case 'off'
     set -U bat_icon 'off'
      set -e i_battery
      barracuda_reload
    case "*"
      echo "$_: $b_lang[36]" $argv
  end
end

#------------------------------------------------------------
# => Environment
#------------------------------------------------------------
# Dark mode
function dark -d 'Set dark mode'
  set -U barracuda_colors $barracuda_colors_dark
  set -U barracuda_icons $barracuda_icons_dark
  set -U i_mode $barracuda_icons[1]
  set -U scheme 'Dark'
  set barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"
  switch $lang
    case 'es' 'español'
      spanish
    case 'en' 'english'
      english
  end
end

# Light mode
function light -d 'Set light mode'
  set -U barracuda_colors $barracuda_colors_light
  set -U barracuda_icons $barracuda_icons_light
  set -U i_mode $barracuda_icons[1]
  set -U scheme 'Light'
  set barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[12]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"
  switch $lang
    case 'es' 'español'
      spanish
    case 'en' 'english'
      english
  end
end

#------------------------------------------------------------
# => Pre execute
#------------------------------------------------------------
function __barracuda_preexec -d 'Execute after hitting <Enter> before doing anything else'
  set -l cmd (commandline | sed 's|[[:space:]]|\x1e|g')
  if [ $_ = 'fish' ]
    if [ -z $cmd[1] ]
      set -e cmd[1]
    end
    if [ -z $cmd[1] ]
      return
    end
    set -e barracuda_prompt_error[1]
    if not type -q -- $cmd[1]
      if [ -d $cmd[1] ]
        set barracuda_prompt_error (cd $cmd[1] 2>&1)
        and commandline ''
        commandline -f repaint
        return
      end
    end
    switch $cmd[1]
      case 'c'
        if begin
            [ (count $cmd) -gt 1 ]
            and [ $cmd[2] -gt 0 ]
            and [ $cmd[2] -lt $pcount ]
          end
          commandline $prompt_hist[$cmd[2]]
          echo $prompt_hist[$cmd[2]] | xsel
          commandline -f repaint
          return
        end
      case 'cd'
        if [ (count $cmd) -le 2 ]
          set barracuda_prompt_error (eval $cmd 2>&1)
          and commandline ''
          if [ (count $barracuda_prompt_error) -gt 1 ]
            set barracuda_prompt_error $barracuda_prompt_error[1]
          end
          commandline -f repaint
          return
        end
    end
  end
  commandline -f execute
end

#------------------------------------------------------------
# => Fish termination
#------------------------------------------------------------
function __barracuda_on_termination -s HUP -s QUIT -s TERM --on-process %self -d 'Execute when shell terminates'
  set -l item (contains -i %self $barracuda_sessions_active_pid 2> /dev/null)
  __barracuda_detach_session $item
end

#------------------------------------------------------------
# => Directory history
#------------------------------------------------------------
function __barracuda_create_dir_hist -v PWD -d 'Create directory history without duplicates'
  if [ "$pwd_hist_lock" = false ]
    if contains $PWD $$dir_hist
      set -e $dir_hist[1][(contains -i $PWD $$dir_hist)]
    end
    set $dir_hist $$dir_hist $PWD
    set -g dir_hist_val (count $$dir_hist)
  end
end

function __barracuda_cd_prev -d 'Change to previous directory, press H in NORMAL mode.'
  if [ $dir_hist_val -gt 1 ]
    set dir_hist_val (expr $dir_hist_val - 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function __barracuda_cd_next -d 'Change to next directory, press L in NORMAL mode.'
  if [ $dir_hist_val -lt (count $$dir_hist) ]
    set dir_hist_val (expr $dir_hist_val + 1)
    set pwd_hist_lock true
    cd $$dir_hist[1][$dir_hist_val]
    commandline -f repaint
  end
end

function d -d 'List directory history, jump to directory in list with d <number>'
  set -l num_items (expr (count $$dir_hist) - 1)
  if [ $num_items -eq 0 ]
    echo $b_lang[37]
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $$dir_hist[1][(expr $num_items - $argv[1])]
  else
    echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[38] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
    echo -e (set_color $barracuda_colors[5])$b_lang[39] (set_color normal)

    for i in (seq $num_items)
      if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
        set_color $barracuda_colors[9]
      else
        set_color normal
      end
      echo -e "$barracuda_icons[16]" (tabs -2)(expr $num_items - $i)".\t$barracuda_icons[40] "$$dir_hist[1][$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[1]
    set input_length (expr length (expr $num_items - 1))

    echo && echo
    while ! contains $foo $b_lang
      tput cuu 2
      tput ed
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[7](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
      switch "$dir_num"
        case (seq 0 (expr $num_items - 1))
          cd $$dir_hist[1][(expr $num_items - $dir_num)]
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
          return
        case "$yes_no[4]"
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
	  return        
        case "$yes_no[5]"
          while ! contains $foo $b_lang
            tput cuu 2
            tput ed
            read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[5]) $barracuda_icons[7] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
            switch $dir_num
              case (seq 0 (expr $num_items - 1))
                set -e $dir_hist[1][(expr $num_items - $dir_num)] 2> /dev/null
                set dir_hist_val (count $$dir_hist)
                for x in (seq (expr $num_items + 9))
	          tput cuu1
	    	  tput ed
	        end
	        return
              case "$yes_no[4]"
	        for x in (seq (expr $num_items + 9))
	          tput cuu1
	    	  tput ed
	        end
	        return
            end
          end
    end
  end
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
end
end

#------------------------------------------------------------
# => Command history
#------------------------------------------------------------
function __barracuda_create_cmd_hist -e fish_prompt -d 'Create command history without duplicates'
  if [ $_ = 'fish' ]
    set -l IFS ''
    set -l cmd (echo $history[1] | fish_indent | expand -t 4)
    # Create prompt history
    if begin
        [ $pcount -gt 0 ]
        and [ $no_prompt_hist = 'F' ]
      end
      set prompt_hist[$pcount] $cmd
    else
      set no_prompt_hist 'F'
    end
    set pcount (expr $pcount + 1)
    # Create command history
    if not begin
        expr $cmd : '[cdms] ' > /dev/null
        or contains $cmd $barracuda_nocmdhist
      end
      if contains $cmd $$cmd_hist
        set -e $cmd_hist[1][(contains -i $cmd $$cmd_hist)]
      end
      set $cmd_hist $$cmd_hist $cmd
    end
  end
  set fish_bind_mode insert
  __barracuda_urgency
end

function c -d 'List command history, load command from prompt with c <prompt number>'
  set -l num_items (count $$cmd_hist)
  if [ $num_items -eq 0 ]
    echo $b_lang[45]
    return
  end
  echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[43] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
  echo -e (set_color $barracuda_colors[5])$b_lang[44] (set_color normal)
  for i in (seq $num_items)
    if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
      set_color $barracuda_colors[9]
    else
      set_color $barracuda_colors[4]
    end
    set -l item (echo $$cmd_hist[1][$i])
    if test (expr $num_items - $i) -ge 10; set t ''; else; set t '\t';end
    echo -e "$barracuda_icons[16] "(expr $num_items - $i). $t$barracuda_icons[10] $item
  end
  if [ $num_items -eq 1 ]
    set last_item ''
  else
    set last_item '-'(expr $num_items - 1)
  end
  echo -en $barracuda_cursors[1]
  set input_length (expr length (expr $num_items - 1))
  echo && echo
  while ! contains $foo $b_lang
    tput cuu 2
    tput ed
    read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[10](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l cmd_num
    switch $cmd_num
      case (seq 0 (expr $num_items - 1))
        for i in (seq (expr $num_items + 9))
          tput cuu1
          tput ed
        end
        commandline $$cmd_hist[1][(expr $num_items - $cmd_num)]
        return
      case "$yes_no[4]"
        for i in (seq (expr $num_items + 9))
          tput cuu1
          tput ed
        end
        return
      case "$yes_no[5]"
        while ! contains $foo $b_lang
          tput cuu 2
          tput ed
          read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[5]) $barracuda_icons[7] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l cmd_num
            switch "$cmd_num"
              case (seq 0 (expr $num_items - 1))
                set -e $cmd_hist[1][(expr $num_items - $cmd_num)] 2> /dev/null
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                return
              case "$yes_no[4]"
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                return
            end
        end
    end
  end
  set pcount (expr $pcount - 1)
  set no_prompt_hist 'T'
end

#------------------------------------------------------------
# => Bookmarks
#------------------------------------------------------------
function mark -d 'Create bookmark for present working directory.'
  if not contains $PWD $bookmarks
    set -U bookmarks $PWD $bookmarks
    set pwd_hist_lock true
    commandline -f repaint
  end
end

function unmark -d 'Remove bookmark for present working directory, or remove the entry given as argument.'
  set -l num_items (count $bookmarks)
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    set -e bookmarks[(expr $num_items - $argv[1])]
  else if contains $PWD $bookmarks
    set -e bookmarks[(contains -i $PWD $bookmarks)]
  else
    return
  end
  set pwd_hist_lock true
  commandline -f repaint
end

function m -d 'List bookmarks, jump to directory in list with m <number>'
  set -l num_items (count $bookmarks)
  if [ $num_items -eq 0 ]
    echo $b_lang[40]
    return
  end
  if begin
      [ (count $argv) -eq 1 ]
      and [ $argv[1] -ge 0 ]
      and [ $argv[1] -lt $num_items ]
    end
    cd $bookmarks[(expr $num_items - $argv[1])]
  else
    echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[41] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
    echo -e (set_color $barracuda_colors[5])$b_lang[42] (set_color normal)

    for i in (seq $num_items)
      if [ $PWD = $bookmarks[$i] ]
        set_color $barracuda_colors[10]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color $barracuda_colors[9]
        else
          set_color $barracuda_colors[4]
        end
      end
      echo (tabs -2)"$barracuda_icons[16] "(expr $num_items - $i).\t$barracuda_icons[7] $bookmarks[$i] | sed "s|$HOME|~|"
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[1]
    set input_length (expr length (expr $num_items - 1))
    echo && echo
    while ! contains $foo $b_lang
      tput cuu 2
      tput ed
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[5])" $barracuda_icons[11]"(set_color $barracuda_colors[1])" $b_lang[34]"(set_color -o $barracuda_colors[1])"[0""$last_item""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
      switch $dir_num
        case (seq 0 (expr $num_items - 1))
          cd $bookmarks[(expr $num_items - $dir_num)]
          for i in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
          end
          return
        case "$yes_no[4]"
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
	  return        
      end
    end
  end
end

#------------------------------------------------------------
# => Sessions
#------------------------------------------------------------
function __barracuda_delete_zombi_sessions -d 'Delete zombi sessions'
  for i in $barracuda_sessions_active_pid
    if not contains $i %fish
      set -l item (contains -i $i $barracuda_sessions_active_pid)
      set -e barracuda_sessions_active_pid[$item]
      set -e barracuda_sessions_active[$item]
    end
  end
end

function __barracuda_create_new_session -d 'Create a new session'
  set -U barracuda_session_cmd_hist_$argv[1] $$cmd_hist
  set -U barracuda_session_dir_hist_$argv[1] $$dir_hist
  set -U barracuda_sessions $argv[1] $barracuda_sessions
end

function __barracuda_erase_session -d 'Erase current session'
  if [ (count $argv) -eq 1 ]
    switch $lang
      case "es" "español"
        echo -e "Falta un argumento: nombre de la sesión a eliminar."
      case "en" "english"
        echo -e 'Missing argument: name of session to erase'
    end
    return
  end
  if contains $argv[2] $barracuda_sessions_active
    switch $lang
      case "es" "español"
        echo -e "La sesión '$argv[2]' no puede ser eliminada porque actualmente se encuentra activa."
      case "en" "english"
        echo -e "Session '$argv[2]' cannot be erased because it's currently active."
    end
    return
  end
  if contains $argv[2] $barracuda_sessions
    set -e barracuda_session_cmd_hist_$argv[2]
    set -e barracuda_session_dir_hist_$argv[2]
    set -e barracuda_sessions[(contains -i $argv[2] $barracuda_sessions)]
  else
    switch $lang
      case "es" "español"
        echo "No se encontró la sesión '$argv[2]'. "(set_color normal)'Escriba '(set_color $fish_color_command[1])'s '(set_color normal)'para mostrar una lista de las sesiones guardadas.'      
      case "en" "english"
        echo "Session '$argv[2]' not found. "(set_color normal)'Enter '(set_color $fish_color_command[1])'s '(set_color normal)'to show a list of all recorded sessions.'
    end
  end
end

function __barracuda_detach_session -d 'Detach current session'
  set cmd_hist cmd_hist_nosession
  set dir_hist dir_hist_nosession
  if [ -z $$dir_hist ] 2> /dev/null
    set $dir_hist $PWD
  end
  set dir_hist_val (count $$dir_hist)
  set -e barracuda_sessions_active_pid[$argv] 2> /dev/null
  set -e barracuda_sessions_active[$argv] 2> /dev/null
  set barracuda_session_current ''
  cd $$dir_hist[1][$dir_hist_val]
  set no_prompt_hist 'T'
end

function __barracuda_attach_session -d 'Attach session'
  set argv (echo -sn $argv\n | sed 's|[^[:alnum:]]|_|g')
  if contains $argv[1] $barracuda_sessions_active
    wmctrl -a "$barracuda_icons[13] $argv[1]"
  else
    wt "}><(({º> ""[ "$argv[1]" ] - "(date)
    __barracuda_detach_session $argv[-1]
    set barracuda_sessions_active $barracuda_sessions_active $argv[1]
    set barracuda_sessions_active_pid $barracuda_sessions_active_pid %self
    set barracuda_session_current $argv[1]
    if not contains $argv[1] $barracuda_sessions
      __barracuda_create_new_session $argv[1]
    end
    set cmd_hist barracuda_session_cmd_hist_$argv[1]
    set dir_hist barracuda_session_dir_hist_$argv[1]
    if [ -z $$dir_hist ] 2> /dev/null
      set $dir_hist $PWD
    end
    set dir_hist_val (
    count $$dir_hist)
    cd $$dir_hist[1][$dir_hist_val] 2> /dev/null
  end
  set no_prompt_hist 'T'
end

function s -d 'Create, delete or attach session'
  __barracuda_delete_zombi_sessions
  if [ (count $argv) -eq 0 ]
    set -l active_indicator
    set -l num_items (count $barracuda_sessions)
    if [ $num_items -eq 0 ]
      switch $lang
        case "es" "español"
          echo -e "La lista de sesiones está vacía. Escriba "(set_color $barracuda_colors[8])"'s'"(set_color normal)" [nombre-de-sesión] para guardar la sesión actual."
        case "en" "english"
          echo -e "Session list is empty. Enter" (set_color $barracuda_colors[8])"'s'"(set_color normal)" [session-name] to record the current session."
      end
      return
    end
    echo -e \n(set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[46] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
    echo -e (set_color $barracuda_colors[5])$b_lang[47] (set_color normal)

    for i in (seq $num_items)
      if [ $barracuda_sessions[$i] = $barracuda_session_current ]
        set_color $barracuda_colors[10]
      else
        if [ (expr \( $num_items - $i \) \% 2) -eq 0 ]
          set_color $barracuda_colors[9]
        else
          set_color $barracuda_colors[4]
        end
      end
      if contains $barracuda_sessions[$i] $barracuda_sessions_active
        set active_indicator "$barracuda_icons[13] "
      else
        set active_indicator ' '
      end
      echo (tabs -2)"$barracuda_icons[16] "(expr $num_items - $i).\t$barracuda_icons[13] $active_indicator$barracuda_sessions[$i]
    end
    if [ $num_items -eq 1 ]
      set last_item ''
    else
      set last_item '-'(expr $num_items - 1)
    end
    echo -en $barracuda_cursors[1]
    set input_length (expr length (expr $num_items - 1))

    echo && echo
    while ! contains $foo $b_lang
      tput cuu 2
      tput ed
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[13](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l session_num
      set pcount (expr $pcount - 1)
      switch $session_num
        case (seq 0 (expr $num_items - 1))
          set argv[1] $barracuda_sessions[(expr $num_items - $session_num)]
          for i in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
          end
          break
        case "$yes_no[4]"
          for i in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
          end
          return
        case "$yes_no[5]"
          while ! contains $foo $b_lang
            tput cuu 2
            tput ed
            read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[5]) $barracuda_icons[7] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l session_num
            switch "$session_num"
              case (seq 0 (expr $num_items - 1))
                if [ (expr $num_items - $session_num) -gt 0 ]
                  __barracuda_erase_session -e $barracuda_sessions[(expr $num_items - $session_num)]
                  barracuda_reload
                end
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                return
              case "$yes_no[4]"
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                return
            end
          end
      end
    end
  end
  set -l item (contains -i %self $barracuda_sessions_active_pid 2> /dev/null)
  switch $argv[1]
    case '-e'
      __barracuda_erase_session $argv
      tput cuu 3
      tput ed
    case '-d'
      wt ' }><(({º> -' (date)
      __barracuda_detach_session $item
      tput cuu 3
      tput ed
      set pcount (expr $pcount - 1)
    case '-*'
      echo "$_: $b_lang[36] $argv[1]"
    case '*'
      __barracuda_attach_session $argv $item
  end
end

#------------------------------------------------------------
# => Virtual Env segment
#------------------------------------------------------------
function __barracuda_prompt_virtual_env -d 'Return the current virtual env name or other custom environment information'
  if set -q VIRTUAL_ENV; or set -q barracuda_alt_environment
    set_color -b $barracuda_colors[9]
    echo -n ''
    if set -q VIRTUAL_ENV
      echo -n ' '(basename "$VIRTUAL_ENV")' '
    end
    if set -q barracuda_alt_environment
      echo -n ' '(eval "$barracuda_alt_environment")' '
    end
    set_color -b $barracuda_colors[1] $barracuda_colors[9]
  end
end

#------------------------------------------------------------
# => Git segment
#------------------------------------------------------------
function __barracuda_prompt_git_branch -d 'Return the current branch name'
  set -l branch (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  if not test $branch > /dev/null
    set -l position (command git describe --contains --all HEAD 2> /dev/null)
    if not test $position > /dev/null
      set -l commit (command git rev-parse HEAD 2> /dev/null | sed 's|\(^.......\).*|\1|')
      if test $commit
        set_color -b $barracuda_colors[11]
        switch $pwd_style
          case short long
            echo -n ''(set_color $barracuda_colors[1])" $barracuda_icons[4] "$commit' '(set_color $barracuda_colors[8])
          case none
            echo -n ''
        end
        set_color normal
        set_color $barracuda_colors[11]
      end
    else
      set_color -b $barracuda_colors[3]
      switch $pwd_style
        case short long
          echo -n (set_color $barracuda_colors[1])" $barracuda_icons[4] "$position' '(set_color $barracuda_colors[9])
        case none
          echo -n ''
      end
      set_color normal
      set_color $barracuda_colors[9]
    end
  else
    if not set -q git_show_info
      set -U git_show_info 'on'
    end
    set_color -b $barracuda_colors[3]
    switch $pwd_style
      case short long
        if test $git_show_info = 'on'
          set -g git_dirty (expr (count (git status -sb)) - 1)
          set -g git_ahead_behind (string split '-' (git rev-list --left-right --count origin/master...origin/$branch | sed "s/\t/-/g"))
          set -l git_ahead $git_ahead_behind[2]
          set -l git_behind $git_ahead_behind[1]

          if test $git_dirty -gt 0
            set  git_status_info "$git_status_info "(set_color $barracuda_colors[1])"$barracuda_icons[41]$git_dirty"
          end
          if test $git_ahead -gt 0
            set git_status_info "$git_status_info "(set_color $barracuda_colors[1])"$barracuda_icons[42]$git_ahead"
          end
          if test $git_behind -gt 0
            set git_status_info "$git_status_info "(set_color $barracuda_colors[1])"$barracuda_icons[43]$git_behind"
          end
        else
          set git_status_info ''
        end
        set -g i_git_info $git_status_info
        echo -en (set_color $barracuda_colors[1])" $barracuda_icons[4] $branch""$git_status_info"' '(set_color $barracuda_colors[3])
      case none
        echo -n ''
    end
    set_color normal
    set_color $barracuda_colors[3]
  end
end

function gitinfo -a opt -d 'Enable/Disable Git repository info'
  switch $opt
    case 'on'
      set -U git_show_info 'on'
    case 'off'
      set -U git_show_info 'off'
    case '*'
      echo "$_: $b_lang[36] $argv"
  end
end

#------------------------------------------------------------
# => Bind-mode segment
#------------------------------------------------------------
function __barracuda_prompt_bindmode -d 'Displays the current mode'
  switch $fish_bind_mode
    case default
      set barracuda_current_bindmode_color $barracuda_colors[12]
      echo -en $barracuda_cursors[2](set_color $barracuda_colors[12])
    case insert
      set barracuda_current_bindmode_color $barracuda_colors[6]
      echo -en  $barracuda_cursors[1](set_color $barracuda_colors[6])
      if [ "$pwd_hist_lock" = true ]
        set pwd_hist_lock false
        __barracuda_create_dir_hist
      end
    case visual
      set barracuda_current_bindmode_color $barracuda_colors[12]
      echo -en $barracuda_cursors[3](set_color $barracuda_colors[10])
  end
  if [ (count $barracuda_prompt_error) -eq 1 ]
    set barracuda_current_bindmode_color $barracuda_colors[7]
  end
  set_color -b $barracuda_current_bindmode_color $barracuda_colors[1]
  switch $pwd_style
    case short long
      echo -n (set_color -o $barracuda_colors[5])" $pcount "(set_color normal)(set_color -b $barracuda_colors[5] $barracuda_current_bindmode_color)(set_color -b $barracuda_colors[5])(set_color 000)" $lang "(set_color normal)(set_color -b $barracuda_colors[2])(set_color $barracuda_colors[5])
  end
  set_color $barracuda_colors[5]
end

#------------------------------------------------------------
# => Symbols segment
#------------------------------------------------------------
# Left prompt
function __barracuda_prompt_left_symbols -d 'Display symbols'
    set -l symbols_urgent 'F'
    set -l symbols (set_color -b $barracuda_colors[2])''

    set -l jobs (jobs | wc -l | tr -d '[:space:]')
    if [ -e ~/.taskrc ]
        set todo (task due.before:sunday 2> /dev/null | tail -1 | cut -f1 -d' ')
        set overdue (task due.before:today 2> /dev/null | tail -1 | cut -f1 -d' ')
    end
    if [ -e ~/.reminders ]
        set appointments (rem -a | cut -f1 -d' ')
    end
    if [ (count $todo) -eq 0 ]
        set todo 0
    end
    if [ (count $overdue) -eq 0 ]
        set overdue 0
    end
    if [ (count $appointments) -eq 0 ]
        set appointments 0
    end

    if [ $symbols_style = 'symbols' ]
        if [ $barracuda_session_current != '' ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[13]"
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[11]"
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $barracuda_colors[6])' V'
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color -o $barracuda_colors[6])' R'
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[17]"
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[18]"
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[6])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[6])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols" $barracuda_icons[29]"
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[8]"
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[14]"
        else
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[15]"
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[38]"
            set symbols_urgent 'T'
        end
    else
        if [ $barracuda_session_current != '' ] 2> /dev/null
            set symbols $symbols(set_color $barracuda_colors[6])' '(expr (count $barracuda_sessions) - (contains -i $barracuda_session_current $barracuda_sessions))
            set symbols_urgent 'T'
        end
        if contains $PWD $bookmarks
            set symbols $symbols(set_color $barracuda_colors[6])' '(expr (count $bookmarks) - (contains -i $PWD $bookmarks))
        end
        if set -q -x VIM
            set symbols $symbols(set_color -o $barracuda_colors[6])' V'(set_color normal)(set_color -b $barracuda_colors[2])
            set symbols_urgent 'T'
        end
        if set -q -x RANGER_LEVEL
            set symbols $symbols(set_color $barracuda_colors[6])' '$RANGER_LEVEL
            set symbols_urgent 'T'
        end
        if [ $jobs -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[6])' '$jobs
            set symbols_urgent 'T'
        end
        if [ ! -w . ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[18]"(set_color normal)(set_color -b $barracuda_colors[2])
        end
        if [ $todo -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[6])
        end
        if [ $overdue -gt 0 ]
            set symbols $symbols(set_color $barracuda_colors[6])
        end
        if [ (expr $todo + $overdue) -gt 0 ]
            set symbols $symbols" $todo"
            set symbols_urgent 'T'
        end
        if [ $appointments -gt 0 ]
            set symbols $symbols(set_color 222)" $appointments"
            set symbols_urgent 'T'
        end
        if [ $last_status -eq 0 ]
            set symbols $symbols(set_color 222)' '$last_status
        else
            set symbols $symbols(set_color 222)' '$last_status
        end
        if [ $USER = 'root' ]
            set symbols $symbols(set_color -o $barracuda_colors[6])" $barracuda_icons[38]"
            set symbols_urgent 'T'
        end
    end
    set symbols $symbols(set_color $barracuda_colors[2])' '(set_color normal)(set_color $barracuda_colors[2])
    switch $pwd_style
        case none
            if test $symbols_urgent = 'T'
                set symbols (set_color -b $barracuda_colors[2])''(set_color normal)(set_color $barracuda_colors[2])
            else
                set symbols ''
            end
    end
    echo -n $symbols
end

# Right prompt
function __barracuda_right_prompt_symbols -d 'Display symbols'
  battery_level
  set -l r_symbols (set_color -b black $barracuda_colors[6])''
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_os"
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_mode"
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_bell"
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_battery"
  echo -n $r_symbols
end

#------------------------------------------------------------
# => Backup (Termux)
#------------------------------------------------------------
# ------------------------- #
if test $b_os = 'Android'; and test -e "$PATH/termux-info"
function backup -a opt file_name -d 'Backup file system'
  [ $file_name ]; or set file_name 'Backup'
  set -g tmp_dir $HOME/.backup_termux
  set -g bkup_dir $HOME/storage/shared
  set -g bkup1 $bkup_dir/.backup_termux
  set -g bkup2 $tmp_dir

function __backup__ -V file_name
  echo "home/storage/"\n"home/.backup_termux/"\n"home/exclude"\n"home/termux_backup_log.txt"\n"usr/tmp"\n"home/.suroot/"\n > $HOME/exclude

  set current_path (pwd)
  set bkup_date (date +%s)
  set file $file_name-$bkup_date
  set f_count_total (find $termux_path/. -type f | wc -l)
  if test -d $tmp_dir
    set f_count_bkup (find $tmp_dir/. -type f | wc -l)
  else
    set f_count_bkup 0
  end
  set f_count (expr $f_count_total - $f_count_bkup)
  set -g text (set_color -o cb4b16)
  set -g frame (set_color -o white)
  set -g normal (set_color normal)

  echo -e (set_color -b black $barracuda_colors[9])\n''(set_color -b $barracuda_colors[9] -o 000)" Backup v$barracuda_version "$normal(set_color -b black $barracuda_colors[9])''$normal
  echo -e \n(set_color -b black $barracuda_colors[5])$b_lang[1]$normal
  set_color $barracuda_colors[4]; rsync -av --exclude-from=$termux_path/home/exclude $termux_path/ $tmp_dir/$file/ | pv -lpes $f_count >/dev/null

  set f_count_tmp (find $tmp_dir/$file/. -type f | wc -l)

  cd $tmp_dir/$file
  echo -e \n(set_color -b black $barracuda_colors[5])$b_lang[2]$normal
  set_color $barracuda_colors[4] && tar -czf - * 2>/dev/null | pv -leps $f_count_tmp > $tmp_dir/$file.tar.gz
  rm -Rf $tmp_dir/$file $HOME/exclude
  cd $current_path
  functions -e __backup__
end

 switch $opt
   # ------ List ------
   case '-l' '--list'
     if test ! -d $bkup1 -a ! -d $bkup2
         echo $b_lang[3]
         return
     end

     if test -d $bkup1 -o -d $bkup2
       set list (ls -gh $bkup1 $bkup2 2>/dev/null | grep --color=never ".tar.gz" | awk '{print $8"\t"$4"\t\t"$6"-"$5"-"$7}' | sort -nr)
       set list1 (ls $bkup1 $bkup2 2>/dev/null | grep --color=never ".tar.gz" | sort -nr)
       set -l num_items (count $list1)

       if [ $num_items -eq 0 ]
         echo $b_lang[3]
         return
       else
         echo
         echo (set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[24] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
         echo (set_color $barracuda_colors[5])$b_lang[23] (set_color normal)

         for i in (seq $num_items)
           set even_odd (math $i % 2)
           if test $even_odd -eq 0
             set line_color $barracuda_colors[4]
           else
             set line_color $barracuda_colors[9]
           end
           echo -e (tabs -2)(set_color $line_color)$i.\t$barracuda_icons[21] $list[$i]
         end
       end
     end

   # ------ Delete ------
   case '-d' '--delete'
     if test ! -d $bkup1 -a ! -d $bkup2
       echo $b_lang[3]
     end
     if test -d $bkup1 -o -d $bkup2
       set list (ls -gh $bkup1 $bkup2 2>/dev/null | grep --color=never ".tar.gz" | awk '{print $8"  "$4"  "$6"-"$5"-"$7}' | sort -nr)
       set list1 (ls $bkup1 $bkup2 2>/dev/null | grep --color=never ".tar.gz" | awk '{print $8}' | sort -nr)
       set -l num_items (count $list1)

       if [ $num_items -eq 0 ]
         echo $b_lang[3]
         return 1
       else
         echo
         echo (set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[24] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
         echo (set_color -o $barracuda_colors[5])"$b_lang[23]" (set_color normal)

         for i in (seq $num_items)
           set even_odd (math $i % 2)
           if test $even_odd -eq 0
             set line_color  $barracuda_colors[4]
           else
             set line_color $barracuda_colors[9]
           end
           echo -e (tabs -2)(set_color $line_color)$i.\t$barracuda_icons[21] $list[$i]
         end

	 echo && echo
         echo -en $barracuda_cursors[1]
         set -l input_length (expr length (expr $num_items))
	 while ! contains $foo $b_lang
	   tput cuu 2
	   tput ed
           read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[12] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[4]"(set_color -o 000)""[1-"$num_items"] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[5]"(set_color -o 000)""["$yes_no[3]"] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[26]"(set_color -o 000)""["$yes_no[4]"] (set_color -b $barracuda_colors[9] normal)(set_color -b black $barracuda_colors[9])""""(set_color normal)' -n $input_length -l bkup_file
           switch $bkup_file
             case (seq 0 (expr $num_items))
               while ! contains $foo $b_lang
                 tput cuu 2
                 tput ed
                 read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[12] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[6]"(set_color -o 000)"["$bkup_file"]" (set_color normal)(set_color -b $barracuda_colors[9] 000)"("$yes_no[1]"/"$yes_no[2]")" (set_color -b normal $barracuda_colors[9])""(set_color normal)' -n 1 -l confirm
                 switch $confirm
                   case "$yes_no[1]"
                     rm -f $bkup1/$list1[$bkup_file]
                     rm -f $bkup2/$list1[$bkup_file]
                     cd $current_path
       		     if test -e $PATH/termux-toast
    		       termux-toast -b "#222222" -g top -c white $b_lang[27]
  		     end
  	             for x in (seq (expr $num_items + 9))
	               tput cuu1
	               tput ed
	             end
                     return
        	   case "$yes_no[2]"
		     for x in (seq (expr $num_items + 9))
		       tput cuu1
	               tput ed
		     end
	             return
                  end
             end
            case "$yes_no[4]"
	      for x in (seq (expr $num_items + 9))
	        tput cuu1
	        tput ed
	      end
              return
            case "$yes_no[3]"
             while ! contains $foo $b_lang
             tput cuu 2
             tput ed
             read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5])" $barracuda_icons[12]"(set_color normal)(set_color -b $barracuda_colors[9] 000) $b_lang[7] (set_color -b normal $barracuda_colors[9])""(set_color normal)' -n 1 -l argv
               switch $argv
                 case "$yes_no[1]"
                     rm -Rf $HOME/.backup_termux
                     rm -Rf $bkup_dir/.backup_termux
                     cd $current_path
		     if test -e $PATH/termux-toast
		       termux-toast -b "#222222" -g top -c white $b_lang[28]
		     end
	             for x in (seq (expr $num_items + 9))
	               tput cuu1
	               tput ed
	             end
                     return
        	  case "$yes_no[2]"
		      for x in (seq (expr $num_items + 9))
		        tput cuu1
	    		tput ed
		      end
    		      return
               end
             end
         end
         end
       end
     end

   # ------ Help ------
   case '-h' '--help' ''
     echo
     echo "$b_lang[12]";echo "$b_lang[13]"\n; echo "$b_lang[14]"
     echo "$b_lang[15]"\n; echo "$b_lang[16]"; echo "$b_lang[17]"
     echo "$b_lang[18]"; echo "$b_lang[19]"; echo "$b_lang[20]"\n
     echo "$b_lang[21]"; echo "$b_lang[22]"\n; echo "$b_lang[25]"
     return

   # ------ Create ------
   case '-c' '--create'
     if test -d $HOME/storage
       if test -d $tmp_dir
         mkdir -p $bkup1
         mv -f $tmp_dir/*.tar.gz $bkup1/ 2>/dev/null
         __backup__ $file_name
         cp -rf $tmp_dir/ $bkup_dir/ 2>/dev/null
         rm -Rf $tmp_dir
       else
         mkdir -p $tmp_dir
         __backup__ $file_name
         cp -rf $tmp_dir/ $bkup_dir/ 2>/dev/null
         rm -Rf $tmp_dir
       end
     else
       mkdir -p $tmp_dir 2>/dev/null
       echo "$b_lang[8]"\n"$b_lang[9]"
       echo "$b_lang[10]"(set_color $barracuda_colors[9])' termux-setup-storage'$normal\n
       __backup__ $file_name
     end

     if test -e $termux_path/usr/bin/termux-toast
       termux-toast -b "#222222" -g top -c "#$barracuda_colors[4]" $b_lang[11]
     end

   case '*'
     echo "$_: $b_lang[36] $argv"
     return
 end
end
end

#------------------------------------------------------------
# => Font selection (Termux)
#------------------------------------------------------------
if test -f $PREFIX/bin/termux-info
function chfont -d 'Change font'
  echo
  echo (set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[31] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
  for n in (seq (count $fonts))
    set_color $barracuda_colors[9]
    if test "$$fonts[$n]" = "$font"
      set_color $barracuda_colors[10]
    end
      echo $n. $$fonts[$n] | sed "s/Monofur/Monofur (Default)/g"
      set_color $barracuda_colors[9]
  end

  function __set_font__ -a sfont -d 'Set selected font'
    if ! cmp -s $theme_path/fonts/$font.ttf $HOME/.termux/font.ttf 2> /dev/null
      rm -f $HOME/.termux/font.ttf 2>/dev/null
      cp -f $theme_path/fonts/$font.ttf $HOME/.termux/font.ttf 2>/dev/null
    end
    if test -e $PATH/termux-toast
      termux-toast -b "#222222" -g top -c white $b_lang[33] $fonts[$b_font]
    end
    termux-reload-settings

    for x in (seq (expr (count $fonts) + 8))
      tput cuu1
      tput ed
    end
  end

  echo && echo
  while ! contains $foo $b_lang
    tput cuu 2
    tput ed
    read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[19] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[32]"(set_color -o 000)""[1-4] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[26]"(set_color -o 000)""["$yes_no[4]"] (set_color normal)(set_color -b black $barracuda_colors[9])""""(set_color normal)' -n 1 -g b_font
      if contains $b_font (seq (count $fonts))
        set -U font $$fonts[$b_font]
        __set_font__
        break
      else if test $b_font = $yes_no[4]
         for x in (seq (expr (count $fonts) + 8))
           tput cuu1
           tput ed
         end
         break
      end
  end
end
end

#------------------------------------------------------------
# => Colored Man Pages
#------------------------------------------------------------
function cless -d "Configure less to colorize styled text using environment variables before executing a command that will use less"
    set -l bold_ansi_code (set_color $barracuda_colors[5]) #"\u001b[1m"
    set -l underline_ansi_code "\u001b[4m"
    set -l reversed_ansi_code "\u001b[7m"
    set -l reset_ansi_code (set_color normal)(set_color $barracuda_colors[4])
    set -l teal_ansi_code (set_color $barracuda_colors[5]) #(set_color -o ea0)
    set -l green_ansi_code (set_color $barracuda_colors[8]) #"\u001b[38;5;70m"
    set -l gold_ansi_code "\u001b[38;5;220m"

    set -x LESS_TERMCAP_md (printf $bold_ansi_code$teal_ansi_code) # start bold
    set -x LESS_TERMCAP_me (printf $reset_ansi_code) # end bold
    set -x LESS_TERMCAP_us (printf $underline_ansi_code$green_ansi_code ) # start underline
    set -x LESS_TERMCAP_ue (printf $reset_ansi_code ) # end underline
    set -x LESS_TERMCAP_so (printf $reversed_ansi_code$gold_ansi_code) # start standout
    set -x LESS_TERMCAP_se (printf $reset_ansi_code) # end standout
    set -x LESSCHARSET 'UTF-8' #us-ascii, iso-8859-1, utf-8
    set -x LANG 'es_ES.UTF-8'

    $argv
end

function man --wraps man -d "Run man with added colors"
    set --local --export MANPATH $MANPATH

    if test -z "$MANPATH"
        if set path (command man -p 2>/dev/null)
            set MANPATH (string replace --regex '[^/]+$' '' $path)
        else
            set MANPATH ""
        end
    end

    # prepend the directory of fish and barracuda manpages to MANPATH
    set fish_manpath $__fish_data_dir/man
    set barracuda_manpath $theme_path/man
        
    if test -d $fish_manpath
        set --prepend MANPATH $fish_manpath
    end

    if test -d $barracuda_manpath
        set --prepend MANPATH $barracuda_manpath
    end

    cless (command --search man ) $argv 
end

#------------------------------------------------------------
# => Update Git project
#------------------------------------------------------------
function gitupdate -d 'Update Git project'
  set -l branch (command git describe --contains --all HEAD 2> /dev/null )
  if not test $branch > /dev/null
    echo (set_color $fish_color_error)'Este NO es un proyecto Git'
  else
    set -l add (command git add . #2> /dev/null)
    if test add
      read -p "echo 'Descripción: '" -l desc
      [ $desc ]; or set desc 'Update files'
      command git commit -am "$desc"
      git push -f origin $branch
      echo; echo 'Proyecto actualizado'
    end
  end
end

###############################################################################
# => Prompt initialization
###############################################################################
set -g barracuda_prompt_error
set -g barracuda_current_bindmode_color
set -U barracuda_sessions_active $barracuda_sessions_active
set -U barracuda_sessions_active_pid $barracuda_sessions_active_pid
set -g barracuda_session_current ''
set -g cmd_hist_nosession
set -g cmd_hist cmd_hist_nosession
set -g CMD_DURATION 0
set -g dir_hist_nosession
set -g dir_hist dir_hist_nosession
set -g pwd_hist_lock true
set -g pcount 1
set -g prompt_hist
set -g no_prompt_hist 'F'
set -g symbols_style 'symbols'

#------------------------------------------------------------
# Break
#------------------------------------------------------------
function __break__ #-s INT -d 'Custom break function'
#  trap INT
  echo \n"$b_lang[30]"
  cd $PWD
end

#------------------------------------------------------------
# Load user defined key bindings
#------------------------------------------------------------
if functions --query fish_user_key_bindings
  fish_user_key_bindings
end

#------------------------------------------------------------
# Set favorite editor
#------------------------------------------------------------
if not set -q EDITOR
  set -g EDITOR nano
end

#------------------------------------------------------------
# Source config file
#------------------------------------------------------------
if [ -e $barracuda_config ]
  source $barracuda_config
end

#------------------------------------------------------------
# Don't save in command history
#------------------------------------------------------------
if not set -q barracuda_nocmdhist
  set -U barracuda_nocmdhist 'c' 'd' 'll' 'ls' 'm' 's'
end

#------------------------------------------------------------
# Set PWD segment style
#------------------------------------------------------------
if not set -q barracuda_pwdstyle
  set -U barracuda_pwdstyle short long none
end
set pwd_style $barracuda_pwdstyle[1]

#------------------------------------------------------------
# Cd to newest bookmark if this is a login shell
#------------------------------------------------------------
if not begin
    set -q -x LOGIN
    or set -q -x RANGER_LEVEL
    or set -q -x VIM
  end 2> /dev/null
  if not set -q barracuda_no_cd_bookmark
    if set -q bookmarks[1]
      cd $bookmarks[1]
    end
  end
end
set -x LOGIN $USER

###############################################################################
# => Left prompt
###############################################################################

function fish_prompt -d 'Write out the left prompt of the barracuda theme'
  echo
  fish_vi_key_bindings
  set slash (set_color -o)(set_color normal)(set_color -b $barracuda_colors[9])(set_color 000)
  set -l realhome ~
  set -l my_path (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)
  set -l short_working_dir (string replace -ar '(\.?[^/]{''})[^/]*/' '$1/' $my_path)

  if [ (string length (pwd)) -lt (expr (tput cols) - 5) ]
    set working_dir (pwd)
  else
    set working_dir $short_working_dir
  end
  echo -e (set_color -b black)(set_color $barracuda_colors[9])''(set_color -b $barracuda_colors[9])(set_color 000) $working_dir (set_color normal)(set_color $barracuda_colors[9])'' | sed "s/\//$slash/g"  
  set -g last_status $status
  echo -n -s (__barracuda_prompt_bindmode) (__barracuda_prompt_git_branch) (__barracuda_prompt_left_symbols) (set_color normal)(set_color $barracuda_colors[2]) 
end

###############################################################################
# => Right prompt
###############################################################################
function fish_right_prompt -d 'Show system info'
  echo -n -s (__barracuda_right_prompt_symbols)(set_color -b black $barracuda_colors[6])''(set_color normal)
end
