#!/usr/bin/env bash
# r11u19 boundary: every LANDED pass arm this pass could reach, compiled with
# BOTH binaries; any database that moves is then scored against the GOLDEN.
# Reads the file list on fd 3, children </dev/null; asserts PROCESSED==LISTED.
set -u
PRIS=${PRIS:-/tmp/r11u19_bin/pris.bin}
LAW=${LAW:-/tmp/r11u19_bin/law.bin}
SL=/home/heyfey/git-repos/Surelog/build/bin/surelog
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
OUT=${OUT:-/tmp/r11u19_bnd}
LIST=${1:?file list}
# Entries may be absolute, or RELATIVE to $REPO (the committed BND.list.txt is
# repo-relative so it carries no operator's paths).
REPO=${REPO:-/home/heyfey/git-repos/slang-uhdm}
mkdir -p $OUT
n=0; moved=0
while IFS= read -r f <&3; do
  [ -n "$f" ] || continue
  case "$f" in /*) : ;; *) f=$REPO/$f ;; esac
  n=$((n+1))
  key=$(echo "$f" | sed 's#^/##; s#/#_#g')
  d=$OUT/$key; mkdir -p $d
  for tag in pris law; do
    b=$PRIS; [ $tag = law ] && b=$LAW
    ( cd $(dirname "$f") && $b $(basename "$f") --single-unit --nobuiltin -o $d/$tag.uhdm > $d/$tag.log 2>&1 </dev/null; echo "rc=$?" > $d/$tag.rc )
    if [ -f $d/$tag.uhdm ]; then $DUMP $d/$tag.uhdm 2>&1 | sed "s@$d/@@g; s@, id:[0-9]*@@g; s@\b\(pris\|law\)\.uhdm@X.uhdm@g" | sort > $d/$tag.norm; else : > $d/$tag.norm; fi
  done
  dl=$(diff $d/pris.norm $d/law.norm | grep -c '^[<>]'; true)
  printf "%-58s pris_%s law_%s norm_delta=%s\n" "$key" "$(cat $d/pris.rc)" "$(cat $d/law.rc)" "$dl"
  [ "$dl" != 0 ] && moved=$((moved+1))
done 3< "$LIST"
echo "PROCESSED=$n LISTED=$(grep -c . $LIST) MOVED=$moved"
