#!/usr/bin/env bash
# v109 verifier arm runner: golden + pristine + patched, BOTH views, nets + cmp.
set -u
SV=$(readlink -f "$1"); N=$(basename "$SV" .sv); W=/tmp/v109_w/$N
A=/tmp/v109_bin/pris.bin; B=/tmp/v109_bin/pat.bin; CEN=/tmp/v109_bin/cen109
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
SL=$HOME/git-repos/Surelog/build/bin/surelog
rm -rf "$W"; mkdir -p "$W"; : > "$W/cmds.txt"
run() { echo "CMD $*" >> "$W/cmds.txt"; "$@" > /dev/null 2>&1; echo "rc=$? $*" >> "$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""; [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$A" "$SV" $EF -o "$W/a_$v.uhdm"
  run "$B" "$SV" $EF -o "$W/b_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  for t in "G:$G" "A:$W/a_$v.uhdm" "B:$W/b_$v.uhdm"; do
    tg=${t%%:*}; f=${t#*:}
    [ -f "$f" ] && "$CEN" "$f" "$tg" > "$W/cen.$tg.$v.txt" 2>>"$W/cen.err" || : > "$W/cen.$tg.$v.txt"
  done
  if [ -f "$G" ]; then
    "$CMP" "$G" "$W/a_$v.uhdm" > "$W/cmp.a.$v" 2>&1; echo "cmp.a.$v rc=$? lines=$(wc -l < $W/cmp.a.$v)" >> "$W/cmds.txt"
    "$CMP" "$G" "$W/b_$v.uhdm" > "$W/cmp.b.$v" 2>&1; echo "cmp.b.$v rc=$? lines=$(wc -l < $W/cmp.b.$v)" >> "$W/cmds.txt"
  fi
done
echo "### $N   rc-nonzero: $(grep '^rc=' $W/cmds.txt | grep -cv '^rc=0'; true)"
for v in def elab; do
  echo "--- view=$v  cmp lines PRIS=$(wc -l < $W/cmp.a.$v 2>/dev/null) PAT=$(wc -l < $W/cmp.b.$v 2>/dev/null)"
  join -a1 -a2 -j1 -o 0,1.2,2.2 -e '.' \
    <(grep -P '\tNET\t.*\tIMPL\t' $W/cen.G.$v.txt | awk -F'\t' '{print $5"|"$7"\t"$6}' | sort -u) \
    <(grep -P '\tNET\t.*\tIMPL\t' $W/cen.A.$v.txt | awk -F'\t' '{print $5"|"$7"\t"$6}' | sort -u) \
    2>/dev/null > $W/j1
  join -a1 -a2 -j1 -o 0,1.2,1.3,2.2 -e '.' $W/j1 \
    <(grep -P '\tNET\t.*\tIMPL\t' $W/cen.B.$v.txt | awk -F'\t' '{print $5"|"$7"\t"$6}' | sort -u) \
    2>/dev/null | awk '{printf "  %-42s G=%-14s PRIS=%-14s PAT=%-14s %s\n",$1,$2,$3,$4,($2==$4?"":($2==$3?"<<< PRIS-RIGHT PAT-WRONG":"~"))}'
done
