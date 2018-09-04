#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

./walletresetkmd.sh &

./listassetchains | while read chain; do
  ./walletresetac.sh ${chain} &
done
