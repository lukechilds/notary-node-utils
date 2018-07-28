#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

cli="komodo-cli"
args="$@"

./listassetchains | while read chain; do
  echo ${chain}
  ${cli} -ac_name=${chain} ${args}
done
