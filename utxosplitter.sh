#!/bin/bash

target_utxo_count=50
split_threshold=5
cli="komodo-cli"

calc() {
  awk "BEGIN { print "$*" }"
}

./listassetchains | while read symbol; do

  echo "[${symbol}] Targetting ${target_utxo_count} UTXOs"
  echo "[${symbol}] Will only split if we're ${split_threshold} under"

  satoshis=10000
  if [[ ${symbol} = "GAME" ]]; then
    satoshis=100000
  fi
  amount=$(calc $satoshis/100000000)
  echo "[${symbol}] UTXO size is ${amount}"

  utxo_count=$(${cli} -ac_name=${symbol} listunspent | jq -r '.[].amount' | grep ${amount} | wc -l)
  echo "[${symbol}] Current UTXO count is ${utxo_count}"

  utxo_required=$(calc $target_utxo_count-$utxo_count)

  if [[ ${utxo_required} -gt ${split_threshold} ]]; then
    echo "[${symbol}] Splitting ${utxo_required} extra UTXOs"
    echo ./splitfunds ${symbol} ${utxo_required}
  else
    echo "[${symbol}] No action needed"
  fi
done
