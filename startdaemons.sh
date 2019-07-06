#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)
pubkey=$(cat pubkey.txt)

# Komodo
komodod -gen -genproclimit=1 -notary -pubkey=$pubkey &

# Assetchains
if [[ "${server_type}" = "primary" ]]; then
  hushd -pubkey=$pubkey &
  ./startassetchains.sh &
fi

# 3rd party daemons
if [[ "${server_type}" = "secondary" ]]; then
  bitcoind &
  chipsd -pubkey=$pubkey &
  gamecreditsd -pubkey=$pubkey &
  einsteiniumd -pubkey=$pubkey &
  gincoind -pubkey=$pubkey &
  verusd -pubkey=$pubkey &
fi
