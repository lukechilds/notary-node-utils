#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="HUSH"
daemon="hushd -pubkey=${pubkey}"
daemon_process_regex="hushd.*\-pubkey"
cli="hush-cli"
wallet_file="${HOME}/.hush/wallet.dat"
nn_address="t1YZHW5ugppyRKESnJNEXzBtJadJ16Hx94r"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
