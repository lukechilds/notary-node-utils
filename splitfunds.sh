#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin=$1
duplicates=$2

utxo_size=10000
if [[ ${coin} = "GAME" ]]; then
  utxo_size=100000
fi
if [[ ${coin} = "EMC2" ]]; then
  utxo_size=100000
fi

curl http://127.0.0.1:7776 --silent --data "{\"coin\":\"${coin}\",\"agent\":\"iguana\",\"method\":\"splitfunds\",\"satoshis\":${utxo_size},\"sendflag\":1,\"duplicates\":${duplicates}}"
