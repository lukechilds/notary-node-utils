#!/bin/bash

# Coin we're resetting
coin=$1

# Full daemon comand with arguments
# e.g komodod -notary -pubkey=<pubkey>
daemon=$2

# Daemon process regex to grep processes while we're waiting for it to exit
# e.g "komodod.*\-notary"
daemon_process_regex=$3

# Path to daemon cli
# e.g komodo-cli
cli=$4

# Path to wallet.dat
# e.g ~/.komodo/wallet.dat
wallet_file=$5

# Address containing all your funds
nn_address=$6

date=$(date +%Y-%m-%d:%H:%M:%S)

echo "
=========================================================================
Resetting ${coin} wallet ${date}
=========================================================================
coin: \"${coin}\"
daemon: \"${daemon}\"
daemon_process_regex: \"${daemon_process_regex}\"
cli: \"${cli}\"
wallet_file: \"${wallet_file}\"
nn_address: \"${nn_address}\"
========================================================================="

echo "[${coin}] Resetting ${coin} wallet - ${date}"

waitforconfirm () {
  sleep 15
  confirmations=0
  while [[ ${confirmations} -lt 1 ]]; do
    confirmations=$(${cli} gettransaction $1 | jq -r .confirmations)
    sleep 10
  done
}

echo "[${coin}] Generating temp address"
temp_address=$(${cli} getnewaddress)
temp_privkey=$(${cli} dumpprivkey ${temp_address})
echo "[${coin}] Temp address: ${temp_address}"

echo "[${coin}] Saving the NN privkey to a variable so we can import it later"
nn_privkey=$(${cli} dumpprivkey ${nn_address})

echo "[${coin}] Writing the temp privkey to a file incase something goes wrong"
echo ${temp_privkey} >> "${coin}_temp_privkeys"

echo "[${coin}] Sending entire balance to the new adress"
txid=$(${cli} sendtoaddress ${temp_address} $(${cli} getbalance) "" "" true)
echo "[${coin}] Balance sent: ${txid}"

echo "[${coin}] Waiting for confirmation of sent funds"
waitforconfirm ${txid}
echo "[${coin}] Sent funds confirmed"

echo "[${coin}] Stopping the deamon"
${cli} stop

stopped=0
while [[ ${stopped} -eq 0 ]]; do
  sleep 10
  pgrep -f "${daemon_process_regex}"
  outcome=$(echo $?)
  if [[ ${outcome} -ne 0 ]]; then
    stopped=1
  fi
done

echo "[${coin}] Backing up and removing wallet file"
mv "${wallet_file}" "${wallet_file}.${date}.bak"

echo "[${coin}] Restarting the daemon"
${daemon} > /dev/null 2>&1 &

started=0
while [[ ${started} -eq 0 ]]; do
  sleep 15
  ${cli} getbalance > /dev/null 2>&1
  outcome=$(echo $?)
  if [[ ${outcome} -eq 0 ]]; then
    started=1
  fi
done

echo "[${coin}] Importing the temp privkey and rescanning for funds"
${cli} importprivkey ${temp_privkey}

echo "[${coin}] Importing the NN privkey but without rescanning"
${cli} importprivkey ${nn_privkey} "" false

echo "[${coin}] Sending entire balance back to NN address"
txid=$(${cli} sendtoaddress ${nn_address} $(${cli} getbalance) "" "" true)
echo "[${coin}] Balance returned: ${txid}"

echo "[${coin}] Waiting for confirmation of returned funds"
waitforconfirm ${txid}
echo "[${coin}] Returned funds confirmed"

echo "[${coin}] Complete!"
