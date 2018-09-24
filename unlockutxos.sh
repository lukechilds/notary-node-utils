#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally unlock UTXOs for a single coin
# e.g "KMD"
specific_coin=$1

./listcoins.sh | while read coin; do
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "${coin}" ]]; then
    cli=$(./listclis.sh ${coin})
    echo "${coin}: $(${cli} lockunspent true $(${cli} listlockunspent | jq -c .))"
  fi
done
