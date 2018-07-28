#!/bin/bash

# Optionally just get the cli for a single coin
# e.g "KMD"
coin=$1

bitcoin_cli="bitcoin-cli"
chips_cli="chips-cli"
game_cli="gamecredits-cli"
verus_cli="$HOME/VerusCoin/src/verusd"
komodo_cli="komodo-cli"

if [[ -z "${coin}" ]] || [[ "${coin}" = "BTC" ]]; then
  echo ${bitcoin_cli}
fi
if [[ -z "${coin}" ]] || [[ "${coin}" = "CHIPS" ]]; then
  echo ${chips_cli}
fi
if [[ -z "${coin}" ]] || [[ "${coin}" = "GAME" ]]; then
  echo ${game_cli}
fi
if [[ -z "${coin}" ]] || [[ "${coin}" = "VRSC" ]]; then
  echo ${verus_cli}
fi
if [[ -z "${coin}" ]] || [[ "${coin}" = "KMD" ]]; then
  echo ${komodo_cli}
fi

./listassetchains | while read symbol; do
  if [[ -z "${coin}" ]] || [[ "${coin}" = "${symbol}" ]]; then
    echo "${komodo_cli} -ac_name=${symbol}"
  fi
done
