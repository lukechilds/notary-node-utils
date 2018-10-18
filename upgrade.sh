#!/bin/bash
set -euo pipefail
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)
privkey=$(cat privkey.txt)
cli="komodo-cli"
daemon="komodod -notary -pubkey=${pubkey}"

echo "Building latest komodod..."
(cd ~/komodo/ && git checkout dev && git pull && make clean && ./zcutil/build.sh -j12)

echo "Stopping komodod and assetchains..."
./ac-cli.sh stop
${cli} stop

echo "Waiting for them to exit gracefully..."
sleep 20

echo "Starting komodod and assetchains with new binary..."
${daemon} > /dev/null 2>&1 &
./startassetchains.sh > /dev/null 2>&1
sleep 20

echo "Importing privkey..."
./ac-cli.sh importprivkey $privkey

echo "Updating iguana..."
(cd ~/SuperNET/iguana && git checkout dev && git pull && ./m_notary "" notary_nosplit > ~/logs/iguana 2>&1)

echo "Init dPoW..."
(cd ~/SuperNET/iguana && ./dpowassets)
