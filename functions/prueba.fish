function prueba -d 'Just for testings'
  clear
  read -p 'echo Escribe algo: ' -l algo
  if test $algo = 'marv'
    echo Hacker
  else
    echo Naah..
  end
  echo "Escribiste $algo"
end