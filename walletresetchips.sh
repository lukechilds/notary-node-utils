#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="CHIPS"
daemon="chipsd -pubkey=${pubkey}"
daemon_process_regex="chipsd.*\-pubkey"
cli="chips-cli"
wallet_file="${HOME}/.chips/wallet.dat"
nn_address="RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
