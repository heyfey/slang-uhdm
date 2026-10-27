#!/bin/bash
# census.sh <relative .sv path under the repo>: run pristine, law, ver on it (from its own dir; dut.sv honours TOP/FILES)
# prints: path rc_p rc_l rc_v md5_p md5_l md5_v ; outputs under /tmp/v11u444_scr/cen/<key>/{p,l,v}.uhdm
REPO=/home/heyfey/git-repos/slang-uhdm; f=$1; d=$REPO/$(dirname $f); b=$(basename $f)
key=$(echo $f | sed 's|/|_|g'); o=/tmp/v11u444_scr/cen/$key; rm -rf $o; mkdir -p $o
SRC=$b; GT=
if [ $b = dut.sv ]; then [ -f $d/FILES ] && SRC=$(cat $d/FILES); [ -f $d/TOP ] && GT="--top $(cat $d/TOP)"; fi
line="$f"; ms=""
for t in p l v; do
  B=/tmp/v11u444_bin/${CEN_BIN_p:-pristine}; [ $t = l ] && B=/tmp/v11u444_bin/law; [ $t = v ] && B=/tmp/v11u444_bin/${VERBIN:-ver2}
  (cd $d && timeout 120 $B $SRC $GT --single-unit --nobuiltin -o $o/$t.uhdm > /dev/null 2>&1; echo $? > $o/$t.rc)
  line="$line $(cat $o/$t.rc)"; ms="$ms $( [ -f $o/$t.uhdm ] && md5sum < $o/$t.uhdm | cut -c1-8 || echo none)"
done
echo "$line$ms"
