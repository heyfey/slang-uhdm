#!/bin/bash
# audit.sh <sweepdir> <bin>: count cmds.txt slang lines naming bin vs others
for c in surelog uhdm2rtlil; do
  t=$(find $1/$c -name cmds.txt | wc -l); ok=$(find $1/$c -name cmds.txt -exec grep -l "^slang: *$2 " {} + | wc -l)
  echo "$c: $ok of $t cmds.txt name $2"
done
