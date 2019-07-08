#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)

if [[ "${server_type}" = "primary" ]]; then
  echo 7776
elif [[ "${server_type}" = "secondary" ]]; then
  echo 7779
fi
