#!/bin/bash
set -eo pipefail

cli="komodo-cli"
args="$@"

./listassetchains | while read chain; do
  echo ${chain}
  ${cli} -ac_name=${chain} ${args}
done
