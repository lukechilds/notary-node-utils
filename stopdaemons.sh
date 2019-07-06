#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

./listclis.sh | while read cli; do
  ${cli} stop
done
