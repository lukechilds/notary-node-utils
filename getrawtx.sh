#!/bin/bash

coin=$1
txid=$2

cli="komodo-cli"

$cli -ac_name=$coin getrawtransaction $txid
