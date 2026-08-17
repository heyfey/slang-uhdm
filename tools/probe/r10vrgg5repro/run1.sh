#!/usr/bin/env bash
# vrgg5 adversarial single-cell runner: golden Surelog + BASE + PAT, printing
# every <callee> call's argument constant.
#   usage: run1.sh <src.sv> <topmodule> <callee>
# GUARDS: a side with no database prints NO-DATABASE and is COUNTED; argc.py
# exits 3 on a dump with zero calls (printed NO-CALL, counted).
set -u
SRC=${1:?src}; TOP=${2:?top}; CALLEE=${3:?callee}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
BASE=/tmp/vrgg5_base_bin; PAT=/tmp/vrgg5_pat_bin
w=/tmp/vrgg5_adv/wd_$(basename "$SRC" .sv); rm -rf "$w"; mkdir -p "$w"
cp "$SRC" "$w"/
b=$(basename "$SRC")
( cd "$w" && "$SL" -parse -nopython -d uhdm -top "$TOP" "$b" > gold.dump 2> gold.err )
if [ ! -s "$w/gold.dump" ]; then echo "GOLD NO-DATABASE"; else
  python3 /tmp/vrgg5_adv/argc.py "$w/gold.dump" "$(basename $SRC .sv) GOLD" "$CALLEE" || echo "GOLD NO-CALL"
fi
for tag in BASE PAT; do
  bin=$(eval echo "\$$tag")
  ( cd "$w" && "$bin" --single-unit --top "$TOP" "$b" -o $tag.uhdm > $tag.log 2>&1 )
  if [ ! -s "$w/$tag.uhdm" ]; then echo "$tag NO-DATABASE"; sed -n '1,6p' "$w/$tag.log"; continue; fi
  "$DUMP" "$w/$tag.uhdm" > "$w/$tag.dump" 2>&1
  python3 /tmp/vrgg5_adv/argc.py "$w/$tag.dump" "$(basename $SRC .sv) $tag" "$CALLEE" || echo "$tag NO-CALL"
done
