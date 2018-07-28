#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just split UTXOs for a single coin
# e.g "KMD"
specific_coin=$1

target_utxo_count=50
split_threshold=5

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
      echo ./splitfunds ${coin} ${utxo_required}
    else
      echo "[${coin}] No action needed"
    fi
  fi
done
