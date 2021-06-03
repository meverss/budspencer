function gitupdate -d 'Update Git project'
  set -l branch (command git describe --contains --all HEAD 2> /dev/null )
  if not test $branch > /dev/null
    echo 'Este NO es un proyecto Git'
  else
    set add (command git add . 2> /dev/null)
    if test add
      read -p 'echo Descripción: ' -l desc
      [ $desc ]; or set desc 'Update files'
      command git commit -am "$desc"
      git push -f origin $branch
      echo; echo 'Proyecto actualizado'
    else
      echo 'El proyecto ya está actualizado'
    end
  end
end
