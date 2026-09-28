#!/bin/bash
# awayall.sh TAG case... : for each case whose pris/law bytes differ, report AWAY line counts (ELAB honoured via key)
TAG=$1; shift
for c in "$@"; do k=$(echo "$c${ELAB:-}${XENV:-}" | md5sum | cut -c1-10); J=/tmp/v11u201_judge/$TAG
  p=$J/pris.bin/$k/ours.uhdm; l=$J/law.bin/$k/ours.uhdm; [ -s $p ] && [ -s $l ] || { echo "$(basename $c) MISSING"; continue; }
  cmp -s $p $l && continue
  r=$(N=1000 bash $V201DRV/away.sh $(cat $J/pris.bin/$k/golden.path)/golden.uhdm $p $l)
  ax=$(sed -n '/AWAY extra/,/AWAY missing/p' <<< "$r" | grep -vc '^--'); am=$(sed -n '/AWAY missing/,$p' <<< "$r" | grep -vc '^--')
  echo "$(basename $c)	$(head -1 <<< "$r")	awayExtra=$ax awayMissing=$am"; done
