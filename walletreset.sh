#!/bin/bash
#Config area
komodo_data=~/.komodo                           #default would be ~/.komodo
komodopath=komodo-cli                           #path to komodo-cli
komododpath=komodod                             #path to komodod
NNaddress=RPxsaGNqTKzPnbm5q7QXwu7b6EZWuLxJG3    #Your NN address key goes here
source ~/komodo/src/pubkey.txt                  #path to your pubkey.txt
args="-gen -genproclimit=1"                     #Any special args you pass komodod on start
DATE=`date +%Y-%m-%d:%H:%M:%S`                  #get todays date for your wallet.dat backup file
currdir=$(echo $PWD)                            #get the working directory

waitforconfirm () {
  sleep 15
  confirmations=0
  while [[ $confirmations -lt 1 ]]; do
    confirmations=$($komodopath gettransaction $1 | jq -r .confirmations)
    sleep 10
  done
}

echo "[KMD] Get new address and privkey for it, best to use new one each time to avoid bloating wallet."
NewAddress=$($komodopath getnewaddress)
NewPrivKey=$($komodopath dumpprivkey $NewAddress)

echo "[KMD] Save the NN privkey to a variable so we can import it later."
NNprivkey=$($komodopath dumpprivkey $NNaddress)

echo "[KMD] Add the new privkey to a file, incase something goes wrong we can import it to recover funds"
echo $NewPrivKey >> NewAddressPrivKey

echo "[KMD] Send entire balance to the new adress"
TXID=$($komodopath sendtoaddress $NewAddress $($komodopath getbalance) "" "" true)

echo "[KMD] Check for confirmation of received funds"
waitforconfirm $TXID

echo "[KMD] stop the deamon"
$komodopath stop

echo "[KMD] wait for deamon to stop"
stopped=0
while [[ $stopped -eq 0 ]]; do
  sleep 10
  pgrep -a komodod | grep 'komodod.*\-notary'
  outcome=$(echo $?)
  if [[ $outcome -ne 0 ]]; then
    stopped=1
  fi
done

echo "[KMD] move your old wallet, then return to our working directory"
cd $komodo_data
mv wallet.dat wallet.dat.$DATE.bak
cd $currdir

echo "[KMD] restart the komodo deamon, it will generate a new empty wallet.dat on start"
$komododpath -notary -pubkey=$pubkey $args > /dev/null 2>&1 &

echo "[KMD] wait for deamon to start"
started=0
while [[ $started -eq 0 ]]; do
  sleep 15
  $komodopath getbalance > /dev/null 2>&1
  outcome=$(echo $?)
  if [[ $outcome -eq 0 ]]; then
    started=1
  fi
done

echo "[KMD] import the private keys, we rescan for new address but not for NN address"
$komodopath importprivkey $NewPrivKey
$komodopath importprivkey $NNprivkey "" false

echo "[KMD] Send the entire balance to the NN address"
TXID=$($komodopath sendtoaddress $NNaddress $($komodopath getbalance) "" "" true)

echo "[KMD] Check for confirmation of received funds"
waitforconfirm $TXID

echo "[KMD] Process complete... please launch m_notary and carry out acsplit KMD"
