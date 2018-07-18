#!/bin/bash

source ~/komodo/src/pubkey.txt
DATE=$(date +%Y-%m-%d:%H:%M:%S)
current_dir=$(echo $PWD)

# Coin we're resetting
coin="KMD"

# Full daemon comand with arguments
# e.g komodod -notary -pubkey=<pubkey>
daemon="komodod -gen -genproclimit=1 -notary -pubkey=$pubkey"

# Daemon process regex to grep processes while we're waiting for it to exit
# e.g "komodod.*\-notary"
daemon_process_regex="komodod.*\-notary"

# Path to daemon cli
# e.g komodo-cli
cli="komodo-cli"

# daemon data directory where wallet.dat exists
# e.g ~/.komodo
data_dir="${HOME}/.komodo"

# Address containing all your funds
nn_address="RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3"

echo "
=========================================================================
Resetting ${coin} wallet
=========================================================================
coin: \"${coin}\"
daemon: \"${daemon}\"
daemon_process_regex: \"${daemon_process_regex}\"
cli: \"${cli}\"
data_dir: \"${data_dir}\"
nn_address: \"${nn_address}\"
========================================================================="

waitforconfirm () {
  sleep 15
  confirmations=0
  while [[ $confirmations -lt 1 ]]; do
    confirmations=$($cli gettransaction $1 | jq -r .confirmations)
    sleep 10
  done
}

echo "[$coin] Get temp address and privkey, best to use new one each time to avoid bloating wallet."
temp_address=$($cli getnewaddress)
temp_privkey=$($cli dumpprivkey $temp_address)

echo "[$coin] Save the NN privkey to a variable so we can import it later."
NNprivkey=$($cli dumpprivkey $nn_address)

echo "[$coin] Save the temp privkey to a file, incase something goes wrong we can import it to recover funds"
echo $temp_privkey >> "${coin}_temp_privkeys"

echo "[$coin] Send entire balance to the new adress"
txid=$($cli sendtoaddress $temp_address $($cli getbalance) "" "" true)
echo "[$coin] $txid"

echo "[$coin] Check for confirmation of received funds"
waitforconfirm $txid

echo "[$coin] stop the deamon"
$cli stop

echo "[$coin] wait for deamon to stop"
stopped=0
while [[ $stopped -eq 0 ]]; do
  sleep 10
  pgrep -f "$daemon_process_regex"
  outcome=$(echo $?)
  if [[ $outcome -ne 0 ]]; then
    stopped=1
  fi
done

echo "[$coin] move your old wallet, then return to our working directory"
cd $data_dir
mv wallet.dat wallet.dat.$DATE.bak
cd $current_dir

echo "[$coin] restart the komodo deamon, it will generate a new empty wallet.dat on start"
$daemon > /dev/null 2>&1 &

echo "[$coin] wait for deamon to start"
started=0
while [[ $started -eq 0 ]]; do
  sleep 15
  $cli getbalance > /dev/null 2>&1
  outcome=$(echo $?)
  if [[ $outcome -eq 0 ]]; then
    started=1
  fi
done

echo "[$coin] import the private keys, we rescan for new address but not for NN address"
$cli importprivkey $temp_privkey
$cli importprivkey $NNprivkey "" false

echo "[$coin] Send the entire balance to the NN address"
txid=$($cli sendtoaddress $nn_address $($cli getbalance) "" "" true)
echo "[$coin] $txid"

echo "[$coin] Check for confirmation of received funds"
waitforconfirm $txid

echo "[$coin] Process complete... please launch m_notary and carry out acsplit KMD"
