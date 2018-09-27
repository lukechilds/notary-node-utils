#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
# e.g "KMD"
coin=$1

# Full daemon comand with arguments
# e.g "komodod -notary -pubkey=<pubkey>"
daemon=$2

# Daemon process regex to grep processes while we're waiting for it to exit
# e.g "komodod.*\-notary"
daemon_process_regex=$3

# Path to daemon cli
# e.g "komodo-cli"
cli=$4

# Path to wallet.dat
# e.g "${HOME}/.komodo/wallet.dat"
wallet_file=$5

# Address containing all your funds
# e.g "RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"
address=$6

date=$(date +%Y-%m-%d:%H:%M:%S)

if [[ "${coin}" = "PIRATE" ]]; then
  echo "[${coin}] ERROR: Cannot reset ${coin} wallet with this method"
  exit 1
fi

echo "[${coin}] Resetting ${coin} wallet - ${date}"

waitforconfirm () {
  confirmations=0
  while [[ ${confirmations} -lt 1 ]]; do
    sleep 1
    confirmations=$(${cli} gettransaction $1 | jq -r .confirmations)
    # Keep re-broadcasting
    ${cli} sendrawtransaction $(${cli} getrawtransaction $1) > /dev/null 2>&1
  done
}

echo "[${coin}] Saving the main address privkey to reimport later"
privkey=$(${cli} dumpprivkey ${address})
echo "[${coin}] Main address: ${address}"
echo "[${coin}] Main privkey: ${privkey}"

echo "[${coin}] Generating temp address"
temp_address=$(${cli} getnewaddress)
temp_privkey=$(${cli} dumpprivkey ${temp_address})
echo "[${coin}] Temp address: ${temp_address}"
echo "[${coin}] Temp privkey: ${temp_privkey}"

echo "[${coin}] Writing the temp privkey to a file incase something goes wrong"
echo ${temp_privkey} >> "${coin}_temp_privkeys"

echo "[${coin}] Unlocking all UTXOs"
./unlockutxos.sh ${coin}
echo "[${coin}] UTXOs unlocked"

echo "[${coin}] Sending entire balance to the temp adress"
txid=$(${cli} sendtoaddress ${temp_address} $(${cli} getbalance) "" "" true)
echo "[${coin}] Balance sent TXID: ${txid}"

echo "[${coin}] Waiting for confirmation of sent funds"
waitforconfirm ${txid}
echo "[${coin}] Sent funds confirmed"

echo "[${coin}] Stopping the deamon"
${cli} stop

stopped=0
while [[ ${stopped} -eq 0 ]]; do
  sleep 1
  pgrep -af "${daemon_process_regex}" | grep -v "$0" > /dev/null 2>&1
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
  sleep 1
  ${cli} getbalance > /dev/null 2>&1
  outcome=$(echo $?)
  if [[ ${outcome} -eq 0 ]]; then
    started=1
  fi
done

echo "[${coin}] Importing the temp privkey and rescanning for funds"
${cli} importprivkey ${temp_privkey}

echo "[${coin}] Importing the main privkey but without rescanning"
${cli} importprivkey ${privkey} "" false

echo "[${coin}] Sending entire balance back to main address"
txid=$(${cli} sendtoaddress ${address} $(${cli} getbalance) "" "" true)
echo "[${coin}] Balance returned TXID: ${txid}"

echo "[${coin}] Waiting for confirmation of returned funds"
waitforconfirm ${txid}
echo "[${coin}] Returned funds confirmed"

echo "[${coin}] Running UTXO splitter"
./utxosplitter.sh ${coin}

echo "[${coin}] Wallet reset complete!"
