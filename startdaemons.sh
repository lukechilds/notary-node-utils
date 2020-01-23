#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

server_type=$(cat server_type.txt)
pubkey=$(cat pubkey.txt)

# Komodo
mining_args=""
if [[ "${server_type}" = "primary" ]]; then
  mining_args="-gen -genproclimit=1"
fi
spam_prevention_args="-minrelaytxfee=0.000035 -opretmintxfee=0.004"
komodod $mining_args $spam_prevention_args -notary -pubkey=$pubkey &

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
