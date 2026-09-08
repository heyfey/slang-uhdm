#!/usr/bin/env bash
# r10uvm216 — THE STATIC-ADDRESS FALSE-MOVER TELLS (the four tells recorded at
# r10uvm208 §9, re-run rather than asserted).  MEASUREMENT ONLY.
#
# A committed arm whose source carries NO `export "DPI-C"` item cannot be
# touched by § dpiExportListedAtExportItem216, yet it can still MOVE BYTES: the
# campaign's known static-address false mover bakes a program address into a
# constant, and it shifts whenever the binary grows a page.  This script proves
# or refutes that identification on each arm:
#
#   TELL 1  the OFFICIAL `uhdm-cmp` output is BYTE-IDENTICAL between the two
#           binaries, in BOTH views (same head object, same every line)
#   TELL 2  the whole-dump diff is CONFINED to `|UINT:` constant lines
#   TELL 3  each differing UINT delta is a multiple of the 4096-byte page
#   TELL 4  each binary is DETERMINISTIC on its own (three runs, one md5)
#
# The subroutine-listing census verdict (TO-GOLDEN/AWAY/STILL-WRONG) is scored
# separately by `armscore216.sh`; this script adds the four tells to it.
#
# usage: PRIS=.. PATCHED=.. ./falsemover216.sh <arms-root> <scratch> <out> <rel> [<rel> ...]
set -u
PRIS=${PRIS:?}; PATCHED=${PATCHED:?}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/git-repos/UHDM/build/bin/uhdm-cmp}
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
ROOT=${1:?arms root}; SCR=${2:?scratch}; OUT=${3:?out}; shift 3
mkdir -p "$SCR" || exit 1
: > "$OUT"
bad=0
for rel in "$@"; do
  f=$ROOT/$rel
  [ -f "$f" ] || { echo "ARM $rel MISSING-SOURCE" >> "$OUT"; bad=$((bad+1)); continue; }
  for ev in parse elab; do
    key=$(echo "$rel" | tr '/' '_').$ev
    d=$SCR/$key; rm -rf "$d"; mkdir -p "$d"
    cp "$f" "$d/" 2>/dev/null
    for h in "$(dirname "$f")"/*.svh "$(dirname "$f")"/*.vh; do [ -f "$h" ] && cp "$h" "$d/"; done
    b=$(basename "$f"); ex=""; [ "$ev" = elab ] && ex="--elabuhdm"
    sx="";  [ "$ev" = elab ] && sx="-elabuhdm"
    ( cd "$d" && timeout 300 "$SURELOG" -parse -d coveruhdm -nobuiltin -nocache $sx "$b" > sl.log 2>&1 </dev/null )
    for r in 1 2 3; do
      ( cd "$d" && timeout 300 "$PRIS"    "$b" $ex -o o$r.uhdm > o.log 2>&1 </dev/null )
      ( cd "$d" && timeout 300 "$PATCHED" "$b" $ex -o q$r.uhdm > q.log 2>&1 </dev/null )
    done
    om=$(md5sum "$d"/o?.uhdm 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ',')
    qm=$(md5sum "$d"/q?.uhdm 2>/dev/null | awk '{print $1}' | sort -u | tr '\n' ',')
    t4=DETERMINISTIC
    [ "$(echo "$om" | tr -cd ',' | wc -c)" = 1 ] || t4=PRIS-NONDET
    [ "$(echo "$qm" | tr -cd ',' | wc -c)" = 1 ] || t4="$t4/PAT-NONDET"
    g=$d/slpp_all/surelog.uhdm
    t1=NO-GOLDEN
    if [ -f "$g" ] && [ -f "$d/o1.uhdm" ] && [ -f "$d/q1.uhdm" ]; then
      "$CMP" "$g" "$d/o1.uhdm" > "$d/cmp.o" 2>&1
      "$CMP" "$g" "$d/q1.uhdm" > "$d/cmp.q" 2>&1
      if cmp -s "$d/cmp.o" "$d/cmp.q"; then t1="CMP-IDENTICAL($(wc -l < "$d/cmp.o") lines)"; else t1=CMP-DIFFERS; fi
    fi
    t2=NO-DUMP; t3=-
    if [ -f "$d/o1.uhdm" ] && [ -f "$d/q1.uhdm" ]; then
      "$DUMP" "$d/o1.uhdm" | sed "s|$d||g" > "$d/o.dump" 2>/dev/null
      "$DUMP" "$d/q1.uhdm" | sed "s|$d||g" > "$d/q.dump" 2>/dev/null
      diff "$d/o.dump" "$d/q.dump" > "$d/dump.diff" 2>&1
      nl=$(grep -c '^[<>]' "$d/dump.diff"); true
      nu=$(grep '^[<>]' "$d/dump.diff" | grep -c 'UINT:'); true
      if [ "$nl" = 0 ]; then t2="DUMP-IDENTICAL"
      elif [ "$nl" = "$nu" ]; then t2="UINT-ONLY($nl lines)"
      else t2="OTHER-LINES($((nl-nu)) of $nl)"; fi
      # page-multiple test on each pair of UINT values
      t3=$(paste -d' ' \
            <(grep '^<' "$d/dump.diff" | grep -o 'UINT:[0-9]*' | cut -d: -f2) \
            <(grep '^>' "$d/dump.diff" | grep -o 'UINT:[0-9]*' | cut -d: -f2) \
          | awk '{d=$2-$1; if(d<0)d=-d; if(d%4096!=0){bad++} n++} END{if(n==0)print "-"; else if(bad)print "NOT-PAGE-MULTIPLE("bad"/"n")"; else print "PAGE-MULTIPLE("n")"}')
    fi
    echo "ARM $rel $ev TELL1=$t1 TELL2=$t2 TELL3=$t3 TELL4=$t4" >> "$OUT"
    case "$t1$t2$t3$t4" in
      *CMP-DIFFERS*|*OTHER-LINES*|*NOT-PAGE-MULTIPLE*|*NONDET*) bad=$((bad+1)) ;;
    esac
  done
done
echo "-- ARMS-FAILING-A-TELL: $bad" >> "$OUT"
tail -1 "$OUT"
