#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Too slow
#./walletresetemc2.sh &
#./walletresetgame.sh &

./walletresetchips.sh &
./walletresethush.sh &
./walletresetvrsc.sh &
