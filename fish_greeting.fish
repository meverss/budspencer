function fish_greeting -d "Welcome Message"
  set -U barracuda_version "1.6.1"
  if test -e $termux_path/usr/bin/termux-toast
    termux-toast -b "#222222" -g top -c white "$bg_lang[15]" \n \n '                        }><(({º>'
  end
  echo (set_color -b black)(set_color b58900)''(set_color -b b58900)(set_color -o 000) "Termux - Barracuda v$barracuda_version" (set_color normal)(set_color b58900)''
end
