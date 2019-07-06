#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)
pubkey=$(cat pubkey.txt)

# Komodo
komodod -gen -genproclimit=1 -notary -pubkey=$pubkey &

# Bitcoin and assetchains
if [[ "${server_type}" = "primary" ]]; then
  bitcoind &
  hushd -pubkey=$pubkey &
  ./startassetchains.sh &
fi

# 3rd party daemons
if [[ "${server_type}" = "secondary" ]]; then
  chipsd -pubkey=$pubkey &
  gamecreditsd -pubkey=$pubkey &
  einsteiniumd -pubkey=$pubkey &
  gincoind -pubkey=$pubkey &
  verusd -pubkey=$pubkey &
fi
