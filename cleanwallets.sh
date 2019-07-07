#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

./listcoins.sh | while read coin; do
  ./cleanwallettransactions.sh ${coin} &
done
