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
#     -> Colored Man Pages
#     -> Barracuda help
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
    set -U i_bell $barracuda_icons[3]
  end
else
  function __barracuda_urgency -d 'Ring the bell in order to set the urgency hint flag.'
    set -U i_bell $barracuda_icons[2]
    echo -n \a
  end
end

function bell -a opt -d 'Enable/Disable bell'
  switch $opt
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
# Set default OFF
if not set -q bat_icon; set -U bat_icon 'off'; end

function battery_level -d 'Shows battery level'
if test $bat_icon = 'on'
  set ac_online (string split "=" (cat $ac_info_file | grep 'ONLINE'))[2]

  if [ $ac_online -gt 0 ]
    set -g i_battery "$battery_icons[13] "
  else
    set -l blevel (string split "=" (cat $battery_info_file | grep 'CAPACITY'))[2]
    set -l bstatus (string split "=" (cat $battery_info_file | grep 'STATUS'))[2]

    if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 5)
      set -g i_battery (set_color $barracuda_colors[7])$battery_icons[1]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 6 15)
      set -g i_battery (set_color $barracuda_colors[7])$battery_icons[2]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 16 19)
      set -g i_battery $battery_icons[2]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 20 29)
      set -g i_battery $battery_icons[3]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 30 39)
      set -g i_battery $battery_icons[4]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 40 49)
      set -g i_battery $battery_icons[5]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 50 59)
      set -g i_battery $battery_icons[6]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 60 69)
      set -g i_battery $battery_icons[7]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 70 79)
      set -g i_battery $battery_icons[8]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 80 89)
      set -g i_battery $battery_icons[9]
    else if not [ $bstatus = 'Charging' ]; and contains $blevel (seq 90 99)
      set -g i_battery $battery_icons[10]
    else if not [ $bstatus = 'Charging' ]; and [ $blevel -eq 100 ]
      set -g i_battery $battery_icons[11]
    else if [ $bstatus = 'Charging' ]
      set -g i_battery $battery_icons[12]
    end
  end
end
end

function battery -a opt -d 'Enable/Disable battery icon'
  switch $opt
    case 'on'
      if [ ! -r "/sys/class/power_suply/" ]
	echo $b_lang[64]
        set -U bat_icon 'off'
      else
        set -U bat_icon 'on'
        battery_level
        barracuda_reload
      end
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
# Set scheme
function color_scheme  -v scheme
  set colors "barracuda_colors_$scheme"
  set icons "barracuda_icons_$scheme"
  set -U barracuda_colors $$colors
  set -U barracuda_icons $$icons
  set -U i_scheme $barracuda_icons[1]
  set -U barracuda_cursors "\033]12;#$barracuda_colors[5]\007" "\033]12;#$barracuda_colors[11]\007" "\033]12;#$barracuda_colors[10]\007" "\033]12;#$barracuda_colors[9]\007"
  switch $lang
    case 'es' 'español'
      spanish
    case 'en' 'english'
      english
  end
end

# Dark mode
function dark -d 'Set dark mode'
  set -U scheme $_
end

# Light mode
function light -d 'Set light mode'
  set -U scheme $_
end

if not set -q scheme; set -U scheme dark; end

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
#function __barracuda_on_termination -s HUP -s QUIT -s TERM --on-process %self -d 'Execute when shell terminates'
#  set -l item (contains -i %self $barracuda_sessions_active_pid #2> /dev/null)
#  __barracuda_detach_session $item
#end

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
      echo -e (tabs -2)"$barracuda_icons[14] "(expr $num_items - $i)."\t $barracuda_icons[6] "$$dir_hist[1][$i] | sed "s|$HOME|~|"
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
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[5](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
      switch "$dir_num"
        case (seq 0 (expr $num_items - 1))
          cd $$dir_hist[1][(expr $num_items - $dir_num)]
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
	  set pcount (expr $pcount - 1)
          return
        case "$yes_no[4]"
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
	  set pcount (expr $pcount - 1)
	  return        
        case "$yes_no[5]"
          while ! contains $foo $b_lang
            tput cuu 2
            tput ed
            read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[10] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
            switch $dir_num
              case (seq 0 (expr $num_items - 1))
                set -e $dir_hist[1][(expr $num_items - $dir_num)] 2> /dev/null
                set dir_hist_val (count $$dir_hist)
                for x in (seq (expr $num_items + 9))
	          tput cuu1
	    	  tput ed
	        end
	        set pcount (expr $pcount - 1)
	        return
              case "$yes_no[4]"
	        for x in (seq (expr $num_items + 9))
	          tput cuu1
	    	  tput ed
	        end
	        set pcount (expr $pcount - 1)
	        return
            end
          end
    end
  end
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
    echo -e "$barracuda_icons[14] "(expr $num_items - $i). $t$barracuda_icons[8] $item
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
    read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[8](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l cmd_num
    switch $cmd_num
      case (seq 0 (expr $num_items - 1))
        for i in (seq (expr $num_items + 9))
          tput cuu1
          tput ed
        end
        commandline $$cmd_hist[1][(expr $num_items - $cmd_num)]
        set pcount (expr $pcount - 1)
        return 0
      case "$yes_no[4]"
        for i in (seq (expr $num_items + 9))
          tput cuu1
          tput ed
        end
        set pcount (expr $pcount - 1)
        return 0
      case "$yes_no[5]"
        while ! contains $foo $b_lang
          tput cuu 2
          tput ed
          read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[10] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[5]"(set_color -o $barracuda_colors[1])"[""$yes_no[3]""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l cmd_num
            switch "$cmd_num"
              case (seq 0 (expr $num_items - 1))
                set -e $cmd_hist[1][(expr $num_items - $cmd_num)] 2> /dev/null
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                set pcount (expr $pcount - 1)
                return 0
              case "$yes_no[3]"
                for x in (seq 0 (expr $num_items - 1))
                  set -e $cmd_hist[1][(expr $num_items - $x)] 2>/dev/null
                end
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                set pcount (expr $pcount - 1)
                return 0
              case "$yes_no[4]"
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                set pcount (expr $pcount - 1)
                return 0
            end
        end
    end
  end
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
    return 0
  end
  set pwd_hist_lock true
  commandline -f repaint
end

function m -d 'List bookmarks, jump to directory in list with m <number>'
  set -l num_items (count $bookmarks)
  if [ $num_items -eq 0 ]
    echo $b_lang[40]
    return 0
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
      echo -e (tabs -2)"$barracuda_icons[14] "(expr $num_items - $i).\t$barracuda_icons[9] $bookmarks[$i] | sed "s|$HOME|~|"
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
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1])" $barracuda_icons[9]"(set_color $barracuda_colors[1])" $b_lang[34]"(set_color -o $barracuda_colors[1])"[0""$last_item""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l dir_num
      switch $dir_num
        case (seq 0 (expr $num_items - 1))
          cd $bookmarks[(expr $num_items - $dir_num)]
          for i in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
          end
          set pcount (expr $pcount - 1)
          return 0
        case "$yes_no[4]"
          for x in (seq (expr $num_items + 9))
            tput cuu1
            tput ed
	  end
	  set pcount (expr $pcount - 1)
	  return 0
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
    wmctrl -a "$barracuda_icons[9] $argv[1]"
  else
    wt "}⋟<(({º> ""[ "$argv[1]" ] - "(date)
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
      return 0
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
        set active_indicator "$barracuda_icons[9] "
      else
        set active_indicator ' '
      end
      echo (tabs -2)"$barracuda_icons[14] "(expr $num_items - $i).\t$barracuda_icons[11] $active_indicator$barracuda_sessions[$i]
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
      read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[11](set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[34]"(set_color -o $barracuda_colors[1])"[0$last_item]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[4]"(set_color -o $barracuda_colors[1])"[""$yes_no[5]""]"(set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l session_num
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
          return 0
        case "$yes_no[5]"
          while ! contains $foo $b_lang
            tput cuu 2
            tput ed
            read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[10] (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1])"$b_lang[35]"(set_color -o $barracuda_colors[1])"[0""$last_item""]" (set_color normal)(set_color -b $barracuda_colors[9] $barracuda_colors[1]) "$b_lang[26]"(set_color -o $barracuda_colors[1])"[""$yes_no[4]""]" (set_color -b normal $barracuda_colors[9])""""(set_color normal)' -n $input_length -l session_num
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
                return 0
              case "$yes_no[4]"
                for i in (seq (expr $num_items + 9))
                  tput cuu1
                  tput ed
                end
                return 0
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
      wt ' }⋟<(({º> -' (date)
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
        echo -n (set_color -b $barracuda_colors[9])''(set_color $barracuda_colors[1])" $barracuda_icons[2]"$commit' '(set_color -b $barracuda_colors[9] $barracuda_colors[2])''
      end
    else
      echo -n (set_color -b $barracuda_colors[9])''(set_color $barracuda_colors[1])" $barracuda_icons[2]"$position' '(set_color -b $barracuda_colors[9] $barracuda_colors[2])''
    end
  else
    if not set -q git_show_info
      set -U git_show_info 'on'
    end
    if test $git_show_info = 'on'
      set -g git_dirty (expr (count (git status -sb)) - 1)
      set -g git_ahead_behind (string split '-' (git rev-list --left-right --count origin/master...origin/$branch | sed "s/\t/-/g"))
      set -l git_ahead $git_ahead_behind[2]
      set -l git_behind $git_ahead_behind[1]

      if test $git_dirty -gt 0
        set git_status_info "$git_status_info "(set_color $barracuda_colors[1])$barracuda_icons[28]$git_dirty
      end
      if test $git_ahead -gt 0
        set git_status_info "$git_status_info "(set_color $barracuda_colors[1])$barracuda_icons[29]$git_ahead
      end
      if test $git_behind -gt 0
        set git_status_info "$git_status_info "(set_color $barracuda_colors[1])$barracuda_icons[30]$git_behind
      end
    else
      set git_status_info ''
    end
    set -g i_git_info $git_status_info
    echo -en (set_color -b $barracuda_colors[3])''(set_color $barracuda_colors[1])" $barracuda_icons[2]$branch""$git_status_info"' '(set_color -b $barracuda_colors[2] $barracuda_colors[3])''
  end
end

function gitinfo -a opt -d 'Enable/Disable Git repository info'
  switch $opt
    case 'on'
      set -U git_show_info 'on'
      tput cuu 3
      tput ed
    case 'off'
      set -U git_show_info 'off'
      tput cuu 3
      tput ed
    case '*'
      echo "$_: $b_lang[36] $argv"
  end
end

#------------------------------------------------------------
# => Bind-mode segment
#------------------------------------------------------------
function __barracuda_prompt_bindmode -d 'Displays the current mode'
  switch $lang
    case 'es' 'español'
      if test (tput cols) -le 56; set -U lang 'es'
      else; set -U lang 'español'; end
    case 'en' 'english'
      if test (tput cols) -le 56; set -U lang 'en'
      else; set -U lang 'english'; end
  end
  
  switch $fish_bind_mode
    case default
      set barracuda_current_bindmode_color $barracuda_colors[1]
      echo -en $barracuda_cursors[2]
    case insert
      set barracuda_current_bindmode_color $barracuda_colors[1]
      echo -en  $barracuda_cursors[1]
      if [ "$pwd_hist_lock" = true ]
        set pwd_hist_lock false
        __barracuda_create_dir_hist
      end
    case visual
      set barracuda_current_bindmode_color $barracuda_colors[1]
      echo -en $barracuda_cursors[3]
  end
  if [ (count $barracuda_prompt_error) -eq 1 ]
    set barracuda_current_bindmode_color $barracuda_colors[7]
  end
  set_color -b $barracuda_current_bindmode_color $barracuda_colors[6]
  echo -n ''(set_color -b $barracuda_colors[6] -o $barracuda_colors[5])"$pcount "(set_color normal)(set_color -b $barracuda_colors[5] $barracuda_current_bindmode_color)(set_color -b $barracuda_colors[5])\
          (set_color $barracuda_colors[1])"$lang "(set_color normal)(set_color -b $barracuda_colors[2])(set_color $barracuda_colors[5])
end

#------------------------------------------------------------
# => Symbols segment
#------------------------------------------------------------
# Left prompt
function __barracuda_prompt_left_symbols -d 'Display symbols'
    set -l symbols_urgent 'F'
    set -l symbols (set_color -b $barracuda_colors[2])

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

    if [ $barracuda_session_current != '' ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[11]"
        set symbols_urgent 'T'
    end
    if contains $PWD $bookmarks
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[9]"
    end
    if set -q -x VIM
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[27]"
        set symbols_urgent 'T'
    end
    if set -q -x RANGER_LEVEL
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[25]"
        set symbols_urgent 'T'
    end
    if [ $jobs -gt 0 ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[15]"
        set symbols_urgent 'T'
    end
    if [ ! -w . ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[16]"
    end
    if [ $todo -gt 0 ]
        set symbols $symbols(set_color $barracuda_colors[1])
    end
    if [ $overdue -gt 0 ]
        set symbols $symbols(set_color $barracuda_colors[1])
    end
    if [ (expr $todo + $overdue) -gt 0 ]
        set symbols $symbols" $barracuda_icons[23]"
        set symbols_urgent 'T'
    end
    if [ $appointments -gt 0 ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[7]"
        set symbols_urgent 'T'
    end
    if [ $USER = 'root' ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[18]"
        set symbols_urgent 'T'
    end
    if [ $last_status -eq 0 ]
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[12]"
    else
        set symbols $symbols(set_color $barracuda_colors[1])" $barracuda_icons[13]"
    end
    set symbols $symbols(set_color $barracuda_colors[2])' '(set_color normal)(set_color $barracuda_colors[5])
    echo -en $symbols
end

# Right prompt
function __barracuda_right_prompt_symbols -V bat_icon -d 'Display symbols'
  battery_level
  set -l r_symbols (set_color -b black $barracuda_colors[6])''
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_os"
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_scheme"
  set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])" $i_bell"
  if test $bat_icon = 'on'
    set -l r_symbols $r_symbols(set_color -b $barracuda_colors[6] $barracuda_colors[5])' '(set_color -b $barracuda_colors[5] $barracuda_colors[1])" $i_battery"(set_color -b $barracuda_colors[1] $barracuda_colors[5])''(set_color normal)
    echo -en $r_symbols
  else
    set -l r_symbols $r_symbols(set_color -b $barracuda_colors[1] $barracuda_colors[6])''(set_color normal)
    echo -en $r_symbols
  end
end

#------------------------------------------------------------
# => Backup (Termux)
#------------------------------------------------------------
# ------------------------- #
if test $b_os = 'Android'; and test -e "$PATH/termux-info"
function backup -a opt file_name -d 'Backup file system'
  [ $file_name ]; or set file_name 'Backup'
  set -g tmp_dir $PREFIX/tmp/.barracuda_backup
  set -g ext_strg $HOME/storage/shared
  set -g bkup1 $ext_strg/.barracuda_backup
  set -g bkup2 $HOME/.barracuda_backup
  set -g current_path (pwd)
  if [ -d $ext_strg ]
    set -g bkup_dir $bkup1; else; set -g bkup_dir $bkup2
  end

function __backup__ -V file_name
  echo "home/storage/"\n"home/.barracuda_backup/"\n"home/exclude"\n"usr/tmp"\n"home/.suroot/"\n > $HOME/exclude
  rm -Rf $tmp_dir 2>/dev/null

  set bkup_date (date +%s)
  set file $file_name-$bkup_date
  set -g normal (set_color normal)
  set ignore_list (cat $HOME/exclude 2>/dev/null)
  for x in (seq (expr (count $ignore_list) - 1)); set ignore $ignore "--ignore='"(echo $ignore_list[$x] | sed 's/home\///g' | sed 's/\///g'| sed 's/usr//g')"'";end
  set f_count_raw (expr (ls $termux_path/ -R $ignore 2>/dev/null| wc -l) + (count $ignore))
  if [ -d $bkup2 ]
    set f_count_bkup2 (ls $bkup2/ -R 2>/dev/null | wc -l)
  else
    set f_count_bkup2 0
  end
  set f_count (expr $f_count_raw - $f_count_bkup2)

  mkdir -p $tmp_dir
  echo -e (set_color -b black $barracuda_colors[9])\n''(set_color -b $barracuda_colors[9] -o $barracuda_colors[1])" Backup "$normal(set_color -b black $barracuda_colors[9])''$normal
  echo -e \n(set_color -b black $barracuda_colors[5])$b_lang[1]$normal
  set_color $barracuda_colors[4]
  rsync -av --exclude-from=$termux_path/home/exclude $termux_path $tmp_dir/$file/ | pv -lpes $f_count >/dev/null

  set f_count_tmp (ls $tmp_dir/$file/ -R | wc -l)
  echo -e \n(set_color -b black $barracuda_colors[5])$b_lang[2]$normal
  set_color $barracuda_colors[4]
  tar -czf - $tmp_dir/$file/* 2>/dev/null | pv -leps $f_count_tmp > $tmp_dir/$file.tar.gz

  mkdir -p $bkup_dir
  mv -f $tmp_dir/*.tar.gz $bkup_dir/ 2>/dev/null
  rm -Rf $tmp_dir $HOME/exclude 2>/dev/null
  cd $current_path
  set -e current_path
  set -e bkup_dir
  functions -e __backup__
end

switch $opt
   # ------ List ------
   case '-l' '--list'
     if [ -d $ext_strg ]; and [ -d $bkup2 ]; and [ (count (ls $bkup2)) != 0 ]
       mkdir -p $bkup1
       mv -u $bkup2/*.tar.gz $bkup1/ 2>/dev/null
       rm -Rf $bkup2 2>/dev/null
     end

     if ! [ -d $bkup_dir ]; or [ (count (ls $bkup_dir)) -eq 0 ]
         echo $b_lang[3]
         return
     else
       set list (ls -gh $bkup_dir 2>/dev/null | grep --color=never ".tar.gz" | awk '{print $8"\t"$4"\t\t"$6"-"$5"-"$7}' | sort -nr)
       set num_items (count $list)

       echo
       echo (set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[24] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
       echo (set_color $barracuda_colors[5])$b_lang[23] (set_color normal)

       for i in (seq $num_items)
         set even_odd (expr $i % 2)
           if test $even_odd -eq 0
             set line_color $barracuda_colors[4]
           else
             set line_color $barracuda_colors[9]
           end
           echo -e (tabs -2)(set_color $line_color)$i.\t$barracuda_icons[19] $list[$i]
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
      if [ -d $ext_strg ]; and [ -d $bkup2 ]; and [ count (ls $bkup2) != 0 ]
        mkdir -p $bkup1
        mv -u $bkup2/*.tar.gz $bkup1/ 2>/dev/null
        rm -Rf $bkup2 2>/dev/null
        __backup__ $file_name
      else if ! [ -d $ext_strg ]
        echo "$b_lang[8]"\n"$b_lang[9]"
        echo "$b_lang[10]"(set_color $barracuda_colors[9])' termux-setup-storage'$normal\n
        __backup__ $file_name
      else
        __backup__ $file_name
      end
      if test -e $termux_path/usr/bin/termux-toast
        termux-toast -b "#222222" -g top -c "#$barracuda_colors[4]" $b_lang[11]
      end

   # ------ Delete ------
   case '-d' '--delete'
     if [ -d $ext_strg ]; and [ -d $bkup2 ]; and [ count (ls $bkup2) != 0 ]
       mkdir -p $bkup1
       mv -u $bkup2/*.tar.gz $bkup1/ 2>/dev/null
       rm -Rf $bkup2 2>/dev/null
     end

     if ! [ -d $bkup_dir ]; or [ (count (ls $bkup_dir)) -eq 0 ]
       echo $b_lang[3]
     else
       set list (ls -gh $bkup_dir 2>/dev/null | grep --color=never ".tar.gz" | awk '{print $8"  "$4"  "$6"-"$5"-"$7}' | sort -nr)
       set -l num_items (count $list)
       echo
       echo (set_color -b black $barracuda_colors[9])(set_color -b $barracuda_colors[9] -o 000) $b_lang[24] (set_color normal)(set_color -b black $barracuda_colors[9])(set_color normal)\n
       echo (set_color -o $barracuda_colors[5])"$b_lang[23]" (set_color normal)

       for i in (seq $num_items)
         set even_odd (expr $i % 2)
         if [ $even_odd -eq 0 ]
           set line_color  $barracuda_colors[4]
         else
           set line_color $barracuda_colors[9]
         end
         echo -e (tabs -2)(set_color $line_color)$i.\t$barracuda_icons[19] $list[$i]
       end

       echo && echo
       echo -en $barracuda_cursors[1]
       set -l input_length (expr length (expr $num_items))
       while ! contains $foo $b_lang
	 tput cuu 2
	 tput ed
         read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[10] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[4]"(set_color -o 000)""[1-"$num_items"] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[5]"(set_color -o 000)""["$yes_no[3]"] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[26]"(set_color -o 000)""["$yes_no[4]"] (set_color -b $barracuda_colors[9] normal)(set_color -b black $barracuda_colors[9])""""(set_color normal)' -n $input_length -l bkup_file
           switch $bkup_file
             case (seq 1 (expr $num_items))
               while ! contains $foo $b_lang
                 tput cuu 2
                 tput ed
                 read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1]) $barracuda_icons[10] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[6]"(set_color -o 000)"["$bkup_file"]" (set_color normal)(set_color -b $barracuda_colors[9] 000)"("$yes_no[1]"/"$yes_no[2]")" (set_color -b normal $barracuda_colors[9])""(set_color normal)' -n 1 -l confirm
                 switch $confirm
                   case "$yes_no[1]"
                     set item (echo $list[$bkup_file] | awk '{print $1}')
                     rm -f $bkup_dir/$item 2>/dev/null
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
              read -p 'echo -n \n(set_color -b $barracuda_colors[9] $barracuda_colors[1])" $barracuda_icons[10]"(set_color normal)(set_color -b $barracuda_colors[9] 000) $b_lang[7] (set_color -b normal $barracuda_colors[9])""(set_color normal)' -n 1 -l argv
                switch $argv
                  case "$yes_no[1]"
                    rm -Rf $bkup_dir 2>/dev/null
                    cd $current_path
		    if [ -e $PATH/termux-toast ]
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
    read -p 'echo -n \n(set_color -b $barracuda_colors[9] -o $barracuda_colors[5]) $barracuda_icons[17] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[32]"(set_color -o 000)""[1-4] (set_color normal)(set_color -b $barracuda_colors[9] 000)"$b_lang[26]"(set_color -o 000)""["$yes_no[4]"] (set_color normal)(set_color -b black $barracuda_colors[9])""""(set_color normal)' -n 1 -g b_font
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
    
    if test -d $fish_manpath
        set --prepend MANPATH $fish_manpath
    end

    if test -d $barracuda_manpath
        set --prepend MANPATH $barracuda_manpath
    end

    cless (command --search man) $argv 
end

###############################################################################
# => Barracuda help
###############################################################################
function barracuda_help -d 'Barracuda help'
  set filter "sed 's/<logo>/}⋟<(({>/g; s/<version>/v$barracuda_version/g; s/<i.session>/$barracuda_icons[11]/g; s/<i.bookmark>/$barracuda_icons[9]/g
             s/<i.jobs>/$barracuda_icons[15]/g; s/<i.lock>/$barracuda_icons[16]/g; s/<i.sched>/$barracuda_icons[20]/g; s/<i.appoint>/$barracuda_icons[7]/g
             s/<i.ok>/$barracuda_icons[12]/g; s/<i.error>/$barracuda_icons[13]/g; s/<i.su>/$barracuda_icons[18]/g; s/<i.git.ahead>/$barracuda_icons[29]/g
             s/<i.git.behind>/$barracuda_icons[30]/g; s/<i.git.dirty>/$barracuda_icons[28]/g; s/<i.git.branch>/$barracuda_icons[2]/g; s/<i.linux>/$barracuda_icons[24]/g
             s/<i.android>/$barracuda_icons[23]/g; s/<i.windows>/$barracuda_icons[22]/g; s/<i.osx>/$barracuda_icons[21]/g; s/<i.vim>/$barracuda_icons[27]/g
             s/<i.dark>/$barracuda_icons_dark[1]/g; s/<i.light>/$barracuda_icons_light[1]/g; s/<i.bellon>/$barracuda_icons[4]/g
             s/<i.belloff>/$barracuda_icons[3]/g; s/<i.ranger>/$barracuda_icons[25]/g; s/Barracuda()/Barracuda/g; s/\B-\s/$barracuda_icons[34] /g' "

  mandoc -O width=$COLUMNS $theme_path/help/$man_lang | eval $filter | cless less
end

#------------------------------------------------------------
# => Update Git project
#------------------------------------------------------------
function gitupdate -d 'Update Git project'
  set branch (command git describe --contains --all HEAD 2> /dev/null )
  if not test $branch > /dev/null
    echo (set_color $fish_color_error)'Este NO es un proyecto Git'
  else
    set add (command git add . 2>/dev/null)
    if [ add ]
      read -p "echo 'Descripción: '" desc
      [ $desc ]; or set desc 'Update files'
      command git commit -am "$desc"
      git push
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

#------------------------------------------------------------
# Break
#------------------------------------------------------------
function __break__ #-s INT -d 'Custom break function'
  trap INT
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
# Don't save in command history
#------------------------------------------------------------
if not set -q barracuda_nocmdhist
  set -U barracuda_nocmdhist 'c' 'd' 'll' 'ls' 'm' 's'
end

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
  set -g last_status $status
  set slash (set_color -o)(set_color normal)(set_color -b $barracuda_colors[9])(set_color 000)
  set -l realhome ~
  set -l my_path (string replace -r '^'"$realhome"'($|/)' "~/$1" $PWD)
  set -l short_working_dir (string replace -ar '(\.?[^/]{1,})[^/]*/' '$1/' $my_path)
  fish_vi_key_bindings

  echo -e \n(set_color -b black)(set_color $barracuda_colors[9])''(set_color -b $barracuda_colors[9])(set_color 000) $short_working_dir (set_color normal)(set_color $barracuda_colors[9])'' | sed "s/\//$slash/g"  
  echo -n -s (__barracuda_prompt_bindmode) (__barracuda_prompt_git_branch) (__barracuda_prompt_left_symbols) (set_color normal)(set_color $barracuda_colors[2]) 
end

###############################################################################
# => Right prompt
###############################################################################
function fish_right_prompt -d 'Show right pronpt icons'
  echo -n -s (__barracuda_right_prompt_symbols)
end
