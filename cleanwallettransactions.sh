#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
coin=$1

if [[ -z "${coin}" ]]; then
  echo "No coin set, can't clean wallet transactions!"
  exit
fi

cli=$(./listclis.sh ${coin})

result=$($cli cleanwallettransactions)
result_formatted=$(echo $result | jq -r '"Total Transactions: \(.total_transactons) | Remaining Transactions: \(.remaining_transactons) | Removed Transactions: \(.removed_transactions)"')

echo "[$coin] $(date) | $result_formatted"
