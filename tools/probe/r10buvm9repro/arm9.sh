#!/usr/bin/env bash
# r10buvm9repro/arm9.sh — ONE arm: run Surelog and slang-uhdm on one .sv in the
# SAME directory (a UHDM database records the source file's ABSOLUTE path, so
# two different CWDs make every object differ — buvm8's bndarms8 trap), census
# both with r10buvm9cen, and print the typespec vpiInstance cells.
#
#   usage: BIN=<slang-uhdm> arm9.sh <file.sv> [grep-regex]
#
# Prints, per typespec that is LISTED (package / class / module listing) and
# NAMED, one row:  <kind>|<name>|<listed>   GOLD=<view> OURS=<view>
# where <view> is ELAB / DEF / NONE / <other instance kind>.
set -u
BIN=${BIN:?BIN=<slang-uhdm binary>}
SRC=${1:?file.sv}
PAT=${2:-.}
SL=$HOME/git-repos/Surelog/build/bin/surelog
CEN=/tmp/r10buvm9cen
[ -x "$BIN" ] || { echo "FATAL no BIN $BIN"; exit 3; }
[ -x "$CEN" ] || { echo "FATAL no census $CEN (run build9.sh)"; exit 3; }
B=$(basename "$SRC" .sv)
W=$(mktemp -d /tmp/r10buvm9_arm_XXXXXX)
cp "$SRC" "$W/$B.sv"
cd "$W" || exit 3
"$SL" -parse "$B.sv" -mt 0 -mp 0 -d coveruhdm -nocache -nobuiltin > sl.log 2>&1
G=$(ls slpp_all/surelog.uhdm 2>/dev/null || true)
if [ -z "$G" ]; then echo "SURELOG_FAIL $B (see $W/sl.log)"; tail -5 sl.log; exit 4; fi
"$BIN" "$B.sv" --single-unit --nobuiltin -o ours.uhdm > su.log 2>&1
if [ ! -s ours.uhdm ]; then echo "SLANG_REJECT $B (see $W/su.log)"; tail -5 su.log; exit 5; fi
"$CEN" "$G" G > g.txt 2>&1
"$CEN" ours.uhdm P > p.txt 2>&1
# The ELAB package id on each side = the pkgid of the PKGTS rows tagged ELAB.
gid=$(awk '$1=="PKG" && $3=="ELAB"{print $5; exit}' g.txt); gid=${gid#id=}
pid=$(awk '$1=="PKG" && $3=="ELAB"{print $5; exit}' p.txt); pid=${pid#id=}
[ -n "$gid" ] || { echo "FATAL: no ELAB package in golden (arm has no package?)"; exit 6; }
[ -n "$pid" ] || { echo "FATAL: no ELAB package in ours"; exit 6; }
norm() { # $1=file $2=tag $3=elabpkgid
  grep "^TS $2 " "$1" | awk -v ep="$3" '{iv="";ls="";for(i=1;i<=NF;i++){if($i ~ /^inst=/) iv=substr($i,6); if($i ~ /^listed=/) ls=substr($i,8)}
    v="DEF"; if(iv=="-") v="NONE"; else if(iv ~ ("\\" ep "$")) v="ELAB"; else if(iv !~ /^package:/) {split(iv,q,":"); v=q[1]}
    if(ls!="-" && $4!="<anon>") print $3"|"$4"|"ls"\t"v}' | LC_ALL=C sort -u
}
norm g.txt G "$gid" > gk.txt
norm p.txt P "$pid" > pk.txt
echo "== arm $B   goldenElabPkg=$gid oursElabPkg=$pid   wd=$W"
LC_ALL=C join -t$'\t' -a1 -a2 -e MISSING -o 0,1.2,2.2 -j1 gk.txt pk.txt |
  grep -E "$PAT" |
  awk -F'\t' '{printf "%-4s %-70s GOLD=%-8s OURS=%s\n", ($2==$3?"ok":"DIFF"), $1, $2, $3}'
echo "-- $(LC_ALL=C join -t$'\t' -j1 gk.txt pk.txt | awk -F'\t' '$2!=$3' | wc -l) DIFF of $(wc -l < gk.txt) golden-listed named typespecs"
