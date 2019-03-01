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
iguana_age_threshold="120"

echo "[${coin}] Checking mining UTXOs - ${date}"

mining_rewards=$(${cli} listunspent | jq -r 'map(select(.spendable == true and .amount != 0.0001))')
no_of_mining_utxos=$(echo $mining_rewards | jq -r 'length')
total_mining_rewards=$(echo $mining_rewards | jq -r '[ .[].amount ] | add')

old_igunan_utxos=$(${cli} listunspent | jq -r "map(select(.spendable == true and .amount == 0.0001 and .confirmations > ${iguana_age_threshold}))")
no_of_iguana_utxos=$(echo $old_igunan_utxos | jq -r 'length')
total_iguana_utxos=$(echo $old_igunan_utxos | jq -r '[ .[].amount ] | add')

echo "[${coin}] ${no_of_mining_utxos} mining UTXOs totalling ${total_mining_rewards} ${coin}"
echo "[${coin}] ${no_of_iguana_utxos} iguana UTXOs older than ${iguana_age_threshold} confs totalling ${total_iguana_utxos} ${coin}"

no_of_utxos=$(calc $no_of_mining_utxos+$no_of_iguana_utxos)
amount_of_utxos=$(calc $total_mining_rewards+$total_iguana_utxos)

if [[ $no_of_utxos -gt 1 ]]; then
  output_amount=$(calc $amount_of_utxos-$txfee)

  transaction_inputs=$(jq -r --argjson mining_rewards "$mining_rewards" --argjson old_igunan_utxos "$old_igunan_utxos" -n '$mining_rewards + $old_igunan_utxos | [.[] | {txid, vout}]')
  transaction_outputs="{\"$address\":$output_amount}"

  echo "[${coin}] Consolidating down ${output_amount} ${coin} to ${address}"

  raw_tx=$(${cli} createrawtransaction "$transaction_inputs" "$transaction_outputs")
  signed_raw_tx=$(${cli} signrawtransaction "${raw_tx}" | jq -r '.hex')
  txid=$(${cli} sendrawtransaction "$signed_raw_tx")

  echo "[${coin}] TXID: ${txid}"
fi
