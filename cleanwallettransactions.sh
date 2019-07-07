#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
coin=$1

possible_coins="
KMD
HUSH3
$(./listassetchains)
"

function list_include_item {
  local list="$1"
  local item="$2"
  if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
    result=0
  else
    result=1
  fi
  return $result
}

if [[ -z "${coin}" ]]; then
  echo "No coin set, can't clean wallet transactions!"
  exit
fi

list_include_item "$possible_coins" "$coin"
result=$?
if [[ $result = 1 ]]; then
  echo "[$coin] $(date) | No clean wallet transaction RPC method available for this coin"
  exit
fi

cli=$(./listclis.sh ${coin})

result=$($cli cleanwallettransactions)
result_formatted=$(echo $result | jq -r '"Total Transactions: \(.total_transactons) | Remaining Transactions: \(.remaining_transactons) | Removed Transactions: \(.removed_transactions)"')

echo "[$coin] $(date) | $result_formatted"
