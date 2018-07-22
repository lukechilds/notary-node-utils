#!/bin/bash

cli="komodo-cli"

./listassetchains | while read symbol; do
  echo "${symbol}: $(${cli} -ac_name=${symbol} listunspent | grep amount | wc -l)"
done
