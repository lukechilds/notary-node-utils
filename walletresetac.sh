#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

# Coin we're resetting
coin=$1

daemon="komodod $(./listassetchainparams ${coin}) -pubkey=${pubkey}"
daemon_process_regex="komodod.*\-ac_name=${coin}"
cli="komodo-cli -ac_name=${coin}"
wallet_file="${HOME}/.komodo/${coin}/wallet.dat"
nn_address="RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
