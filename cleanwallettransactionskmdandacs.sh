#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

./cleanwallettransactions.sh KMD &

./listassetchains | while read chain; do
  ./cleanwallettransactions.sh ${chain} &
done
