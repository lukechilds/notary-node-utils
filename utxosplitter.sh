#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just split UTXOs for a single coin
# e.g "KMD"
specific_coin=$1

target_utxo_count=50
split_threshold=25

date=$(date +%Y-%m-%d:%H:%M:%S)

calc() {
  awk "BEGIN { print "$*" }"
}

echo "----------------------------------------"
echo "Splitting UTXOs - ${date}"
echo "Targetting ${target_utxo_count} UTXOs"
echo "Will only split if we're ${split_threshold} under"
echo "----------------------------------------"

./listcoins.sh | while read coin; do
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "${coin}" ]]; then
    cli=$(./listclis.sh ${coin})

    satoshis=10000
    if [[ ${coin} = "GAME" ]]; then
      satoshis=100000
    fi
    amount=$(calc $satoshis/100000000)

    utxo_count=$(${cli} listunspent | jq -r '.[].amount' | grep ${amount} | wc -l)
    echo "[${coin}] Current UTXO count is ${utxo_count}"

    utxo_required=$(calc $target_utxo_count-$utxo_count)

    if [[ ${utxo_required} -gt ${split_threshold} ]]; then
      echo "[${coin}] Splitting ${utxo_required} extra UTXOs"
      json=$(./splitfunds.sh ${coin} ${utxo_required})
      txid=$(echo ${json} | jq -r '.txid')
      if [[ ${txid} != "null" ]]; then
        echo "[${coin}] Split TXID: ${txid}"
      else
        echo "[${coin}] Error: $(echo ${json} | jq -r '.error')"
      fi
    else
      echo "[${coin}] No action needed"
    fi
  fi
done
