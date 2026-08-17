#!/usr/bin/env bash
# vrgg5 adversarial multi-file runner (adds the REAL rggen_or_reducer.sv).
#   usage: run2.sh <src.sv> <topmodule> <callee>
set -u
SRC=${1:?src}; TOP=${2:?top}; CALLEE=${3:?callee}
SL=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
DUT=$HOME/git-repos/Surelog/third_party/tests/rggen/rggen-sv-rtl/rggen_or_reducer.sv
BASE=/tmp/vrgg5_base_bin; PAT=/tmp/vrgg5_pat_bin
[ -f "$DUT" ] || { echo "FATAL no DUT"; exit 3; }
w=/tmp/vrgg5_adv/wd_$(basename "$SRC" .sv); rm -rf "$w"; mkdir -p "$w"
cp "$SRC" "$DUT" "$w"/
b=$(basename "$SRC")
( cd "$w" && "$SL" -parse -nopython -d uhdm -top "$TOP" rggen_or_reducer.sv "$b" > gold.dump 2> gold.err )
if [ ! -s "$w/gold.dump" ]; then echo "GOLD NO-DATABASE"; sed -n '1,8p' "$w/gold.err"; else
  python3 /tmp/vrgg5_adv/argc.py "$w/gold.dump" "$(basename $SRC .sv) GOLD" "$CALLEE" || echo "GOLD NO-CALL"
fi
for tag in BASE PAT; do
  bin=$(eval echo "\$$tag")
  ( cd "$w" && "$bin" --single-unit --top "$TOP" rggen_or_reducer.sv "$b" -o $tag.uhdm > $tag.log 2>&1 )
  if [ ! -s "$w/$tag.uhdm" ]; then echo "$tag NO-DATABASE"; sed -n '1,8p' "$w/$tag.log"; continue; fi
  "$DUMP" "$w/$tag.uhdm" > "$w/$tag.dump" 2>&1
  python3 /tmp/vrgg5_adv/argc.py "$w/$tag.dump" "$(basename $SRC .sv) $tag" "$CALLEE" || echo "$tag NO-CALL"
done
