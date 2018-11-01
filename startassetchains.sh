#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

overide_args="$@"
pubkey=$(cat pubkey.txt)
seed_ip=$(getent hosts zero.kolo.supernet.org | awk '{ print $1 }')

./listassetchainparams | while read args; do
  if [[ $args =~ "KMDICE" ]]; then
    cli="fsm-komodod"
  else
    cli="komodod"
  fi
  ${cli} ${args} ${overide_args} -pubkey=${pubkey} -addnode=${seed_ip} &
done
