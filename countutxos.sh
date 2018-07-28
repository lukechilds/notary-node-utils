#!/bin/bash

# Optionally just get the cli for a single coin
# e.g "KMD"
coin=$1

./listcoins.sh | while read coin; do
  if [[ -z "${coin}" ]] || [[ "${coin}" = "BTC" ]]; then
    cli=$(./listclis.sh ${coin})
    echo "${coin}: $(${cli} listunspent | jq -r '.[].amount' | wc -l)"
  fi
done
