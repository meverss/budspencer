function colored_prompt -a sec -d 'Colored prompt'

switch $sec
  case 'path'
  set c_path (string split ''  " "(pwd)" ")
  set n 790; set n1 $n
  if test $n -lt 100
    set n "0"$n; set n1 $n
  end
  set s (math -s0 (string length "$c_path")/20)
  if [ (string length "$c_path") -le 21 ]; set s 1; end

  for z in (seq 1 $s (count $c_path))
      set t $c_path[$z..(math $z + $s - 1)]
      for x in (seq (count $t))
  	set y "$y"(set_color -b $n1)$t[$x](set_color -b normal)
      end

      if ! [ $n1 -eq (math $n + 9) ]
        if test $n1 -ge 100
          set n1 (math $n1 + 1)
        else
          set n1 0(math $n1 + 1)
        end
      end
      set prompt (set_color -b black $n)$y(set_color -b black $n1)
  end
  echo $prompt
 
  case 'prompt'
    echo -n -s (__barracuda_prompt_bindmode) (__barracuda_prompt_node_version) (__barracuda_prompt_git_branch) (__barracuda_prompt_left_symbols) (set_color normal)(set_color $barracuda_colors[2])
end
end
