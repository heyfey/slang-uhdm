#!/bin/bash
# (r11u319: copied from r11u317repro/drivers)
# (r11u317: copied from v11u315repro/drivers)
# (r11u315: copied from r11u313repro/drivers)
# (r11u313: copied from v11u311repro/drivers)
# (v11u311: copied from r11u311repro/drivers)
# (r11u311: copied from r11u309repro/drivers)
# (r11u309: copied from r11u307repro/drivers)
# (r11u307: copied from r11u305repro/drivers)
# (r11u305: copied from r11u303repro/drivers)
# (r11u303: copied from r11u301repro/drivers)
# (r11u299: copied from r11u297repro/drivers)
# (r11u297: copied from r11u295repro/drivers)
# (r11u295: copied from r11u293repro/drivers)
# (r11u293: copied from r11u291repro/drivers)
# (r11u291: copied from r11u289repro/drivers)
# (r11u287: copied from r11u285repro/drivers)
# (r11u285: copied from r11u283repro/drivers)
# (r11u283: copied from r11u281repro/drivers)
# (r11u279: copied from r11u277repro/drivers)
# (r11u277: copied from r11u275repro/drivers)
# (r11u275: copied from r11u273repro/drivers)
# (r11u273: copied from r11u271repro/drivers)
# (r11u271: copied from r11u269repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u263: copied from r11u261repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u247: copied from r11u244repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u238 (from r11u236repro): copied from r11u232repro/drivers)
# (r11u244repro: copied from r11u218dec/drivers/bvmirror.sh) bvmirror.sh <sweep workdir> <mirror root>: hard-link every corpus slang.uhdm of a gate sweep into a mirror
# tree, leaving out every path that names a fenced test (word boundary, from $FENCED; fail closed), so that
# tools/probe/r11v75repro/byteverify.sh never opens a fenced row's database.  Only path names are read here.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bvmirror.sh: export FENCED (r11u179map drivers/env.sh)" >&2; exit 2; }
W=$1; M=$2; rm -rf $M; mkdir -p $M
fre=$(echo $FENCED | sed 's/ /|/g')
n=0; s=0
while read -r p; do
  if echo "$p" | grep -Eqw "$fre"; then s=$((s+1)); continue; fi
  mkdir -p "$M/$(dirname $p)"; ln "$W/$p" "$M/$p"; n=$((n+1))
done < <(cd $W && find surelog uhdm2rtlil downstream -name slang.uhdm | sort)
echo "mirrored=$n fenced_skipped=$s"
