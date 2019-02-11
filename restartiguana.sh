#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

echo "Updating iguana..."
(cd ~/SuperNET/iguana && git checkout dev && git pull && ./m_notary "" notary_nosplit > ~/logs/iguana 2>&1)

echo "Init dPoW..."
(cd ~/SuperNET/iguana && ./dpowassets)
