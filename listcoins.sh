#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)

# Komodo
echo "KMD"

# Bitcoin and assetchains
if [[ "${server_type}" = "primary" ]]; then
  echo "BTC"
  echo "HUSH3"
  ./listassetchains
fi

# 3rd party daemons
if [[ "${server_type}" = "secondary" ]]; then
  echo "CHIPS"
  echo "GAME"
  echo "EMC2"
  echo "GIN"
  echo "VRSC"
fi
