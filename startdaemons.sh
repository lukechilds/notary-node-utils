#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

# Komodo
komodod -gen -genproclimit=1 -notary -pubkey=$pubkey &

# 3rd party daemons
bitcoind &
chipsd -pubkey=$pubkey &
gamecreditsd -pubkey=$pubkey &
einsteiniumd -pubkey=$pubkey &
gincoind -pubkey=$pubkey &
verusd -pubkey=$pubkey &

# Assetchains
hushd -pubkey=$pubkey &
./startassetchains &
