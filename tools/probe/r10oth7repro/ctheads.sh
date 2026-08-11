#!/usr/bin/env bash
# r10oth7 — the HEAD table, before and after, for a list of workdir entries.
# Prints the cmp LINE COUNT (labelled HEAD DEPTH), the dump CONTENT count
# (labelled DISTANCE) and the head OBJECT for each side, so a moved head and a
# moved distance can never be conflated -- r10oth6's lesson that "cmp line count
# is a head-depth measure, not a distance".
#
#   usage: ctheads.sh <pristine-workdir-root> <patched-workdir-root> <name>...
#
# The GOLDEN side is read out of each workdir's own cmds.txt (`golden cache hit
# <dir>` -> <dir>/golden.uhdm), so no golden path is ever guessed.  A missing
# golden or database prints UNMEASURED instead of a number.
set -u
PRI=${1:?pristine workdir root}
FIN=${2:?patched workdir root}
shift 2
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
UC=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
one() {  # <golden> <ours> <tag>
  g=$1; o=$2; tag=$3
  if [ ! -f "$g" ] || [ ! -f "$o" ]; then echo "  $tag: UNMEASURED"; return; fi
  d=$(mktemp -d)
  "$UD" "$g" 2>/dev/null | sed '1d' > "$d/g.dump"
  "$UD" "$o" 2>/dev/null | sed '1d' > "$d/o.dump"
  "$UC" "$g" "$o" > "$d/cmp.log" 2>&1
  cl=$(wc -l < "$d/cmp.log")
  if diff -u "$d/g.dump" "$d/o.dump" > "$d/d.diff"; then c=0; else
    c=$(grep -E '^[-+]' "$d/d.diff" | grep -vcE '^(---|\+\+\+) '); fi
  hd=$(sed -n '3p' "$d/cmp.log" | cut -c1-96)
  echo "  $tag: cmp_lines=$cl (HEAD DEPTH) dump_content=$c (DISTANCE) head=[$hd]"
  rm -rf "$d"
}
# RESOLVE A TEST DIRECTORY -- and this guard is a DEFECT THIS SCRIPT SHIPPED WITH,
# caught at integration by running it.  verify_golden.py names each workdir
# `<Test>-<hash>` (e.g. `SVSwitch-db796243`), so the obvious `ctheads.sh … SVSwitch`
# found no cmds.txt and printed `UNMEASURED (no cmds.txt)` for all four cells --
# a silent zero-information reading that looks like a missing database rather
# than a caller mistake.  A bare name is now GLOBBED to its hashed directory, and
# the two failure modes are reported DIFFERENTLY: NO-SUCH-TEST (the name matches
# no directory) versus AMBIGUOUS (it matches several), neither of which can be
# mistaken for UNMEASURED.
resolve() {  # <root> <mode> <name> -> prints the directory, or a diagnosis
  local root=$1 m=$2 t=$3
  if [ -f "$root/$m/$t/cmds.txt" ]; then echo "$root/$m/$t"; return 0; fi
  local hits=() d
  for d in "$root/$m/$t"-*; do [ -f "$d/cmds.txt" ] && hits+=("$d"); done
  case ${#hits[@]} in
    0) return 1;;
    1) echo "${hits[0]}"; return 0;;
    *) printf 'AMBIGUOUS:%s\n' "${hits[*]}"; return 2;;
  esac
}
for t in "$@"; do
  for m in default testflags; do
    echo "$t / $m"
    for side in PRI FIN; do
      root=$PRI; lbl=pristine; [ "$side" = FIN ] && { root=$FIN; lbl=patched; }
      td=$(resolve "$root" "$m" "$t"); rc=$?
      if [ $rc = 1 ]; then
        echo "  $lbl: NO-SUCH-TEST ($t has no workdir with a cmds.txt under $root/$m)"
        continue
      fi
      if [ $rc = 2 ]; then echo "  $lbl: $td"; continue; fi
      gd=$(sed -n 's/.*golden cache hit \(.*\))/\1/p' "$td/cmds.txt")
      one "$gd/golden.uhdm" "$td/slang.uhdm" "$lbl"
    done
  done
done
