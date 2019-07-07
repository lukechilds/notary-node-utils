#!/bin/bash

while true; do
  text="$(hostname)   $(date '+%H:%M')"
  toilet "$text" --termwidth --gay --font standard
  sleep 1
done
