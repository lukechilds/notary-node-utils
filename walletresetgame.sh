#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="GAME"
daemon="gamecreditsd -pubkey=${pubkey}"
daemon_process_regex="gamecreditsd.*\-pubkey"
cli="gamecredits-cli"
wallet_file="${HOME}/.gamecredits/wallet.dat"
nn_address="GYXbuspVqMo7o4hBHt5XH98HF8tmJCbsaH"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
