function colored_prompt -d 'Colored prompt'
  set c_path (string split ''  " "(pwd)" ")
  set n 689; set n1 $n
  set s (math -s0 (string length "$c_path")/20)
  if [ (string length "$c_path") -le 21 ]; set s 1; end

  for z in (seq 1 $s (count $c_path))
      set t $c_path[$z..(math $z + $s - 1)]
      for x in (seq (count $t))
  	set y "$y"(set_color -b $n1)$t[$x](set_color -b normal)
      end

      if ! [ $n1 -eq (math $n - 9) ]
        set n1 (math $n1 - 1)
      end
      set prompt (set_color -b black $n)$y(set_color -b black $n1)
  end
  echo $prompt
end

#end


#for c in (seq 100 999)
#    printf (set_color -b $c)" $c "(set_color normal) | more
#end