#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

echo "Requesting root..."
sudo true

pubkey=$(cat pubkey.txt)
privkey=$(cat privkey.txt)
cli="komodo-cli"
daemon="komodod -notary -pubkey=${pubkey}"

echo "Building latest komodod..."
(cd ~/komodo/ && git checkout beta && git pull && make clean && ./zcutil/build.sh -j$(nproc))

echo "Symlinking latest komodod binary..."
sudo ln -sf ${HOME}/komodo/src/komodo-cli /usr/local/bin/komodo-cli
sudo ln -sf ${HOME}/komodo/src/komodod /usr/local/bin/komodod

echo "Stopping komodod and assetchains..."
./ac-cli.sh stop
${cli} stop

echo "Waiting for them to exit gracefully..."
sleep 20

echo "Starting komodod and assetchains with new binary..."
${daemon} > /dev/null 2>&1 &
sleep 20
./startassetchains.sh > /dev/null 2>&1
sleep 20

echo "Importing privkey..."
./ac-cli.sh importprivkey $privkey

echo "Updating iguana..."
(cd ~/SuperNET/iguana && git checkout beta && git pull && ./m_notary "" notary_nosplit > ~/logs/iguana 2>&1)

echo "Init dPoW..."
(cd ~/komodo/src && ./dpowassets)
