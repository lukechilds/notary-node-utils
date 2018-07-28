#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

cli="komodod"
overide_args="$@"
pubkey=$(cat pubkey.txt)
seed_ip=$(getent hosts zero.kolo.supernet.org | awk '{ print $1 }')

./listassetchainparams | while read args; do
  ${cli} ${args} ${overide_args} -pubkey=${pubkey} -addnode=${seed_ip} &
done
