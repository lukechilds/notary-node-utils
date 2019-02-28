#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
coin=$1

if [[ -z "${coin}" ]]; then
  echo "No coin set, can't clean wallet transactions!"
  exit
fi

cli=$(./listclis.sh ${coin})

$cli cleanwallettransactions
