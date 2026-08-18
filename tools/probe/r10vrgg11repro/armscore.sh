#!/usr/bin/env bash
# r10vrgg11 — score named single-file arms TOWARD GOLDEN with the whole
# normalised dump (order-blind multiset), not just "it moved".
#   usage: armscore.sh <binA> <binB> <outdir> <file> [<file> ...]
set -u
A=${1:?}; B=${2:?}; O=${3:?}; shift 3
SUR=$HOME/git-repos/Surelog/build/bin/surelog
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$O"
n=0
for f in "$@"; do
  n=$((n+1))
  key=$(echo "$f" | tr '/' '_')
  d=$(dirname "$f"); b=$(basename "$f")
  w=$(mktemp -d /tmp/vrgg11_arm.XXXXXX)
  ( cd "$d" && "$SUR" -parse "$b" -mt 0 -mp 0 -o "$w/sl" >/dev/null 2>&1 </dev/null )
  ( cd "$d" && "$A" "$b" --single-unit -o "$w/a.uhdm" >/dev/null 2>&1 </dev/null )
  ( cd "$d" && "$B" "$b" --single-unit -o "$w/b.uhdm" >/dev/null 2>&1 </dev/null )
  g=$w/sl/slpp_all/surelog.uhdm
  if [ ! -f "$g" ] || [ ! -f "$w/a.uhdm" ] || [ ! -f "$w/b.uhdm" ]; then
    echo "NODB $f"; rm -rf "$w"; continue
  fi
  "$DUMP" "$g"        2>/dev/null | sed "s#$w#<W>#g;s#$d#<D>#g" > "$O/$key.gold.dump"
  "$DUMP" "$w/a.uhdm" 2>/dev/null | sed "s#$w#<W>#g;s#$d#<D>#g" > "$O/$key.base.dump"
  "$DUMP" "$w/b.uhdm" 2>/dev/null | sed "s#$w#<W>#g;s#$d#<D>#g" > "$O/$key.pat.dump"
  rm -rf "$w"
done
echo "-- arms=$n dumped into $O"
