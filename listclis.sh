#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just get the cli for a single coin
# e.g "KMD"
specific_coin=$1

server_type=$(cat server_type.txt)

komodo_cli="komodo-cli"
bitcoin_cli="bitcoin-cli"
chips_cli="chips-cli"
game_cli="gamecredits-cli"
einsteinium_cli="einsteinium-cli"
gincoin_cli="gincoin-cli"
verus_cli="${komodo_cli} -ac_name=VRSC"

# Komodo
if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "KMD" ]]; then
  echo ${komodo_cli}
fi

# Bitcoin and assetchains
if [[ "${server_type}" = "primary" ]]; then
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "BTC" ]]; then
    echo ${bitcoin_cli}
  fi
  ./listassetchains | while read coin; do
    if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "${coin}" ]]; then
      echo "${komodo_cli} -ac_name=${coin}"
    fi
  done
fi

# 3rd party daemons
if [[ "${server_type}" = "secondary" ]]; then
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "CHIPS" ]]; then
    echo ${chips_cli}
  fi
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "GAME" ]]; then
    echo ${game_cli}
  fi
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "EMC2" ]]; then
    echo ${einsteinium_cli}
  fi
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "GIN" ]]; then
    echo ${gincoin_cli}
  fi
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "VRSC" ]]; then
    echo ${verus_cli}
  fi
fi
