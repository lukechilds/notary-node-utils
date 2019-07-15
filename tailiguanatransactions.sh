tail -f ~/logs/iguana | grep --line-buffered '>>>>>>>>>>>' | ts '[%d/%m %H:%M:%S]'
