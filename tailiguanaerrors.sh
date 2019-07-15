tail -f ~/logs/iguana | grep --line-buffered 'error' | ts '[%d/%m %H:%M:%S]'
