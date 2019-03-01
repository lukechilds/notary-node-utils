#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

calc() {
  awk "BEGIN { print "$*" }"
}

coin="KMD"
address="RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"
cli=$(./listclis.sh ${coin})
txfee="0.0002"
date=$(date +%Y-%m-%d:%H:%M:%S)

echo "[${coin}] Checking mining UTXOs - ${date}"

mining_rewards=$(${cli} listunspent | jq -r 'map(select(.spendable == true and .amount != 0.0001))')
no_of_mining_utxos=$(echo $mining_rewards | jq -r 'length')
total_mining_rewards=$(echo $mining_rewards | jq -r '[ .[].amount ] | add')

# also consolidate iguana utxos once they're over a certain age

echo "[${coin}] ${no_of_mining_utxos} mining UTXOs totalling ${total_mining_rewards} ${coin}"

if [[ $no_of_mining_utxos -gt 1 ]]; then
  output_amount=$(calc $total_mining_rewards-$txfee)

  transaction_inputs=$(echo $mining_rewards | jq -r '[.[] | {txid: .txid, vout: .vout}]')
  transaction_outputs="{\"$address\":$output_amount}"

  echo "[${coin}] Consolidating down to ${output_amount} ${coin} to ${address}"

  raw_tx=$(${cli} createrawtransaction "$transaction_inputs" "$transaction_outputs")
  signed_raw_tx=$(${cli} signrawtransaction "${raw_tx}" | jq -r '.hex')
  txid=$(${cli} sendrawtransaction "$signed_raw_tx")

  echo "[${coin}] TXID: ${txid}"
fi
