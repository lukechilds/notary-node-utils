#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)

# Komodo
echo "KMD"

# Assetchains
if [[ "${server_type}" = "primary" ]]; then
  echo "HUSH3"
  ./listassetchains
fi

# 3rd party daemons
if [[ "${server_type}" = "secondary" ]]; then
  echo "BTC"
  echo "CHIPS"
  echo "GAME"
  echo "EMC2"
  echo "GIN"
  echo "VRSC"
fi
