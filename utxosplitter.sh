#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just split UTXOs for a single coin
# e.g "KMD"
coin=$1

kmd_target_utxo_count=75
kmd_split_threshold=50

other_target_utxo_count=10
other_split_threshold=5

date=$(date +%Y-%m-%d:%H:%M:%S)

calc() {
  awk "BEGIN { print "$*" }"
}

waitforconfirm () {
  confirmations=0
  while [[ ${confirmations} -lt 1 ]]; do
    sleep 1
    confirmations=$(${cli} gettransaction $1 | jq -r .confirmations)
    # Keep re-broadcasting
    ${cli} sendrawtransaction $(${cli} getrawtransaction $1) > /dev/null 2>&1
  done
}

if [[ -z "${coin}" ]]; then
  echo "----------------------------------------"
  echo "Splitting UTXOs - ${date}"
  echo "KMD target UTXO count: ${kmd_target_utxo_count}"
  echo "KMD split threshold: ${kmd_split_threshold}"
  echo "Other target UTXO count: ${other_target_utxo_count}"
  echo "Other split threshold: ${other_split_threshold}"
  echo "----------------------------------------"

  ./listcoins.sh | while read coin; do
    ./utxosplitter.sh $coin &
  done;
  exit;
fi

is_assetchain=$(./listassetchains | grep -w ${coin})
cli=$(./listclis.sh ${coin})

if [[ "${coin}" = "KMD" ]]; then
  target_utxo_count=$kmd_target_utxo_count
  split_threshold=$kmd_split_threshold
else
  target_utxo_count=$other_target_utxo_count
  split_threshold=$other_split_threshold
fi

satoshis=10000
if [[ ${coin} = "GAME" ]]; then
  satoshis=100000
fi
if [[ ${coin} = "EMC2" ]]; then
  satoshis=100000
fi
amount=$(calc $satoshis/100000000)

unlocked_utxos=$(${cli} listunspent | jq -r '.[].amount' | grep ${amount} | wc -l)
locked_utxos=$(${cli} listlockunspent | jq -r length)
utxo_count=$(calc ${unlocked_utxos}+${locked_utxos})
echo "[${coin}] Current UTXO count is ${utxo_count}"

if [[ ${utxo_count} = 0 ]] && [[ $is_assetchain ]]; then
  echo "[${coin}] Sending entire balance back to main address"
  txid=$(${cli} sendtoaddress RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3 $(${cli} getbalance) "" "" true)
  echo "[${coin}] Balance returned TXID: ${txid}"

  echo "[${coin}] Waiting for confirmation of returned funds"
  waitforconfirm ${txid}
  echo "[${coin}] Returned funds confirmed"
fi

utxo_required=$(calc ${target_utxo_count}-${utxo_count})

if [[ ${utxo_count} -le ${split_threshold} ]]; then
  echo "[${coin}] Splitting ${utxo_required} extra UTXOs"
  json=$(./splitfunds.sh ${coin} ${utxo_required})
  txid=$(echo ${json} | jq -r '.txid')
  if [[ ${txid} != "null" ]]; then
    echo "[${coin}] Split TXID: ${txid}"
  else
    echo "[${coin}] Error: $(echo ${json} | jq -r '.error')"
  fi
fi
