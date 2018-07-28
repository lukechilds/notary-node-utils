#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

ls -lahS ~/.*/wallet.dat ~/.komodo/*/wallet.dat
