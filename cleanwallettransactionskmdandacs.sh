#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

./cleanwallettransactions.sh KMD &

# HUSH3 isn't uses it's own komodod so isn't in assetchains.json
# we need to call it manually
./cleanwallettransactions.sh HUSH3 &

./listassetchains | while read chain; do
  ./cleanwallettransactions.sh ${chain} &
done
