#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="EMC2"
daemon="einsteiniumd -pubkey=${pubkey}"
daemon_process_regex="einsteiniumd.*\-pubkey"
cli="einsteinium-cli"
wallet_file="${HOME}/.einsteinium/wallet.dat"
nn_address="EXqazLL4HTUjhtzkAnQvrWmM6cc3iirPQJ"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
