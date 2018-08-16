#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

ps aux  | awk '{print $6/1024 "MB " $0}' | awk '{$2=$3=$4=$5=$6=$7=$8=$9=$10=$11=""; print $0}' | grep 'pubkey\|bitcoind\|iguana'|  sort -n
