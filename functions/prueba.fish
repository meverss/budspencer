function prueba -d 'Just for testings'
if ! cmp -s $theme_path/fonts/font.ttf $termux_path/home/.termux/font.ttf
  echo Diferentes
else
  echo Iguales
end
end