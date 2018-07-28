#!/bin/bash

# Optionally just get the cli for a single coin
# e.g "KMD"
specific_coin=$1

target_utxo_count=50
split_threshold=5

calc() {
  awk "BEGIN { print "$*" }"
}

./listcoins.sh | while read coin; do
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "${coin}" ]]; then
    cli=$(./listclis.sh ${coin})

    echo "[${coin}] Targetting ${target_utxo_count} UTXOs"
    echo "[${coin}] Will only split if we're ${split_threshold} under"

    satoshis=10000
    if [[ ${coin} = "GAME" ]]; then
      satoshis=100000
    fi
    amount=$(calc $satoshis/100000000)
    echo "[${coin}] UTXO size is ${amount}"

    utxo_count=$(${cli} -ac_name=${coin} listunspent | jq -r '.[].amount' | grep ${amount} | wc -l)
    echo "[${coin}] Current UTXO count is ${utxo_count}"

    utxo_required=$(calc $target_utxo_count-$utxo_count)

    if [[ ${utxo_required} -gt ${split_threshold} ]]; then
      echo "[${coin}] Splitting ${utxo_required} extra UTXOs"
      echo ./splitfunds ${coin} ${utxo_required}
    else
      echo "[${coin}] No action needed"
    fi
  fi
done
