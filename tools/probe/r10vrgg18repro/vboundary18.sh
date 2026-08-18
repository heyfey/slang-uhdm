#!/usr/bin/env bash
# r10vrgg18repro/vboundary18.sh — WIDE 3-WAY boundary: run BASE, the
# IMPLEMENTER's binary and the VERIFIER's fixed binary over a COPY of the WHOLE
# tools/probe tree (every .sv and .v, subdirectories included, NO path filter)
# and byte-compare the three dumps.
#   usage: vboundary18.sh <outdir>
# LAWS: the file list is read on fd 3; every child gets </dev/null; PROCESSED is
# asserted equal to LISTED; rc is recorded per cell for all three; scratch is
# keyed on the RELATIVE path (three different dut.sv exist in the tree); a
# deliberately-moved cell is planted as the POSITIVE CONTROL.
set -u
O=$1
A=/tmp/vrgg18_bin/slang-uhdm-base
B=/tmp/vrgg18_bin/slang-uhdm-pat
C=/tmp/vrgg18_bin/slang-uhdm-fix
SRC=/tmp/wt_vrgg18pris/tools/probe
CP=$O/tree
rm -rf "$O"; mkdir -p "$O"
cp -r "$SRC" "$CP"
mkdir -p "$CP/_vposctl"
cp /tmp/wt_vrgg18/tools/probe/r10vrgg18repro/cells/v3/v3_vrgg18.sv "$CP/_vposctl/"
( cd "$CP" && find . -type f \( -name '*.sv' -o -name '*.v' \) | sort ) > "$O/list.txt"
LISTED=$(wc -l < "$O/list.txt")
PROC=0; DAB=0; DAC=0; ASYM=0; NODB=0
: > "$O/movers.txt"; : > "$O/rc.txt"
while read -r -u 3 f; do
  PROC=$((PROC+1))
  key=$(echo "$f" | sed 's#^\./##; s#/#__#g')
  d=$(dirname "$CP/$f"); bn=$(basename "$f")
  for t in a b c; do
    case $t in a) X=$A;; b) X=$B;; c) X=$C;; esac
    ( cd "$d" && "$X" "$bn" -o "$O/$key.$t.uhdm" > /dev/null 2>&1 </dev/null )
    eval "rc_$t=$?"
  done
  echo "$f rcA=$rc_a rcB=$rc_b rcC=$rc_c" >> "$O/rc.txt"
  if [ "$rc_a" != "$rc_b" ] || [ "$rc_a" != "$rc_c" ]; then
    ASYM=$((ASYM+1)); echo "ASYM_RC $f $rc_a/$rc_b/$rc_c" >> "$O/movers.txt"
  fi
  if [ -f "$O/$key.a.uhdm" ] && [ -f "$O/$key.b.uhdm" ] && [ -f "$O/$key.c.uhdm" ]; then
    for t in a b c; do
      # NORMALISE the dump: the workdir prefix AND the per-binary .a/.b/.c
      # suffix are both embedded in the database path the dumper prints, so a
      # naive cmp calls every file a mover (measured: 2270 false movers).
      ~/.local/bin/uhdm-dump "$O/$key.$t.uhdm" 2>&1 \
        | sed -e "s#$O##g" -e "s#\.[abc]\.uhdm#.uhdm#g" > "$O/$key.$t.dump"
    done
    kb=0; kc=0
    cmp -s "$O/$key.a.dump" "$O/$key.b.dump" || { DAB=$((DAB+1)); kb=1; }
    cmp -s "$O/$key.a.dump" "$O/$key.c.dump" || { DAC=$((DAC+1)); kc=1; }
    [ $kb = 1 ] && echo "DIFF_A_B $f" >> "$O/movers.txt"
    [ $kc = 1 ] && echo "DIFF_A_C $f" >> "$O/movers.txt"
    if [ $kb = 0 ] && [ $kc = 0 ]; then rm -f "$O/$key".[abc].dump; fi
  else
    if [ -f "$O/$key.a.uhdm" ] || [ -f "$O/$key.b.uhdm" ] || [ -f "$O/$key.c.uhdm" ]; then
      ASYM=$((ASYM+1)); echo "ASYM_DB $f" >> "$O/movers.txt"
    else
      NODB=$((NODB+1))
    fi
  fi
  rm -f "$O/$key".[abc].uhdm
done 3< "$O/list.txt"
echo "LISTED=$LISTED PROCESSED=$PROC NO_DB(all3)=$NODB DIFF_A_B=$DAB DIFF_A_C=$DAC ASYM=$ASYM"
[ "$LISTED" = "$PROC" ] || { echo "FATAL: PROCESSED != LISTED"; exit 2; }
[ "$PROC" -gt 0 ] || { echo "FATAL: PROCESSED == 0"; exit 2; }
