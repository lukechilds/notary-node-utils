#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="KMD"
daemon="komodod -notary -pubkey=${pubkey}"
daemon_process_regex="komodod.*\-notary"
cli="komodo-cli"
wallet_file="${HOME}/.komodo/wallet.dat"
nn_address=$(cat kmd_address.txt)

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
