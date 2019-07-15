ls -d ~/logs/* | grep -v iguana | grep -v stats.log | xargs tail -f
